include:
  - roles.imgbuilder.user
  - golang
  - mercurial
  - git
  - bzr

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

packer-prereq:
  pkg.installed:
    - pkgs:
      - qemu-utils
      - qemu-kvm
      - golang
      - mercurial
      - git
      - bzr

packer:
  file.directory:
    - name: /home/{{ s.user }}/go
    - user: {{ s.user }}
    - group: {{ s.user }}
    - mode: 755
    - makedirs: True
    - require:
      - user: imgbuilder
  git.latest:
    - name: https://github.com/mitchellh/packer.git
    - target: /home/{{ s.user }}/go/src/github.com/mitchellh/packer
    - user: {{ s.user }}
    - submodules: True
    - require:
      - file: packer
      - pkg: packer-prereq
  cmd.wait:
    - name: cd $GOPATH/src/github.com/mitchellh/packer; make
    - user: {{ s.user }}
    - group: {{ s.user }}
    - watch:
      - git: packer
    - require:
      - cmd: packer_updatedeps

go_profile:
  file.managed:
    - name: /home/{{ s.user }}/.profile
    - user: {{ s.user }}
    - group: {{ s.user }}

go_profile-activate:
  file.append:
    - name: /home/{{ s.user }}/.profile
    - text: |
        export GOPATH=/home/{{ s.user }}/go
        export PATH=${GOPATH}/bin:$PATH
    - require:
      - file: go_profile

gox_import:
  cmd.run:
    - name: go get -u github.com/mitchellh/gox
    - user: {{ s.user }}
    - group: {{ s.user }}
    - require:
      - git: packer
      - file: go_profile-activate

packer_updatedeps:
  cmd.run:
    - name: cd $GOPATH/src/github.com/mitchellh/packer; make updatedeps
    - user: {{ s.user }}
    - group: {{ s.user }}
    - watch:
      - git: packer
    - require:
      - cmd: gox_import

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

