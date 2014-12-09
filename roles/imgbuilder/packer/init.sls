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

{% if s.precompiled_packer is defined and s.precompiled_packer == true %}

packer_binary:
  file.directory:
    - name: /usr/local/src/packer-v0.7.2-linux-amd64
    - makedirs: true
  archive.extracted:
    - name: /usr/local/src/packer-v0.7.2-linux-amd64
    - source: https://dl.bintray.com/mitchellh/packer/packer_0.7.2_linux_amd64.zip
    - source_hash: sha256=2e0a7971d0df81996ae1db0fe04291fb39a706cc9e8a2a98e9fe735c7289379f
    - archive_format: zip
    - if_missing: /usr/local/src/packer-v0.7.2-linux-amd64/packer
    - require:
      - file: packer_binary
  cmd.run:
    - name: |
        for n in `ls /usr/local/src/packer-v0.7.2-linux-amd64`; do
            ln -s -f -T /usr/local/src/packer-v0.7.2-linux-amd64/$n /usr/local/bin/$n 
        done
    - require:
      - archive: packer_binary

{% else %}

{% load_yaml as config %}
user: {{ s.user }}
source:
  repo: 'https://github.com/mitchellh/packer.git'
build:
  rev: 'v0.8~1'
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
{{ go_build_from_git(config) }}


packer_templates:
  file.recurse:
    - source: salt://roles/imgbuilder/packer/templates
    - name: {{ s.image_base}}/templates/packer/
    - user: {{ s.user }}
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True
    #- template: jinja

box_add_script:
  file.managed:
    - name: {{ s.image_base}}/templates/packer/vagrant-box-add.sh
    - mode: 775
    - require:
      - file: packer_templates
