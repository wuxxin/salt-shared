include:
  - roles.imgbuilder.user
  - golang

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}
{% from 'golang/lib.sls' import go_build_from_git with context %}

packer:
  pkg.installed:
    - pkgs:
      - qemu-utils
      - qemu-kvm
      - golang
  file.directory:
    - name: /home/{{ s.user }}/go
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 755
    - makedirs: True
    - require:
      - user: imgbuilder
      - pkg: packer

{% for dir in ['tmp/packer_cache', 'build'] %}
{{ s.image_base }}/{{ dir }}:
  file.directory:
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 775
    - makedirs: True
    - require:
      - user: imgbuilder
{% endfor %}

profile_packer_create:
  file.managed:
    - name: /home/{{ s.user }}/.profile
    - user: {{ s.user }}
    - group: {{ s.user }}

profile_packer_settings:
  file.append:
    - name: /home/{{ s.user }}/.profile
    - text: |
        export PACKER_CACHE_DIR={{ s.image_base }}/tmp/packer_cache
    - require:
      - file: profile_packer_create
      - file: {{ s.image_base }}/tmp/packer_cache

{% if s.precompiled_packer is defined and s.precompiled_packer == true %}

{% set version="0.8.3" %}

packer_binary:
  file.directory:
    - name: /usr/local/src/packer-v{{ version }}-linux-amd64
    - makedirs: true
  archive.extracted:
    - name: /usr/local/src/packer-v{{ version }}-linux-amd64
    - source: https://dl.bintray.com/mitchellh/packer/packer_{{ version }}_linux_amd64.zip
    - source_hash: sha256=8fab291c8cc988bd0004195677924ab6846aee5800b6c8696d71d33456701ef6
    - archive_format: zip
    - if_missing: /usr/local/src/packer-v{{ version }}-linux-amd64/packer
    - require:
      - file: packer_binary
  cmd.run:
    - name: |
        for n in `ls /usr/local/src/packer-v{{ version }}-linux-amd64`; do
            chmod +x /usr/local/src/packer-v{{ version }}-linux-amd64/$n
            ln -s -f -T /usr/local/src/packer-v{{ version }}-linux-amd64/$n /usr/local/bin/$n
        done
    - require:
      - archive: packer_binary

{% else %}

{% load_yaml as config %}
user: {{ s.user }}
source:
  repo: 'https://github.com/mitchellh/packer.git'
build:
  rev: ''
  make: 'go get -u github.com/mitchellh/gox && cd $GOPATH/src/github.com/mitchellh/packer && make updatedeps && make dev'
  check: 'packer'
  bin_files: ['packer', 'builder-*', 'command-*', 'packer-*', 'post-processor-*', 'provisioner-*']
{% endload %}
{{ go_build_from_git(config) }}

{% endif %}


{% load_yaml as config %}
user: {{ s.user }}
source:
  repo: 'https://github.com/shaunduncan/packer-provisioner-host-command.git'
build:
  rev: 'latest'
  make: 'cd $GOPATH/src/github.com/shaunduncan/packer-provisioner-host-command && go get -d -v -p 2 ./... && make build'
  check: 'packer-provisioner-host-command'
  bin_files: ['packer-provisioner-host-command']
{% endload %}
{# disabled: { go_build_from_git(config) #}



packer_templates:
  file.recurse:
    - source: salt://roles/imgbuilder/packer/templates
    - name: {{ s.image_base}}/templates/packer/
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True

box_add_script:
  file.managed:
    - name: {{ s.image_base}}/templates/packer/vagrant-box-add.sh
    - mode: 775
    - require:
      - file: packer_templates
