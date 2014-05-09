include:
  - roles.imgbuilder.user
  - golang
  - mercurial
  - git
  - bzr

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
    - name: /home/imgbuilder/go
    - user: imgbuilder
    - group: imgbuilder
    - mode: 755
    - makedirs: True
    - require:
      - user: imgbuilder
  git.latest:
    - name: https://github.com/mitchellh/packer.git
    - target: /home/imgbuilder/go/src/github.com/mitchellh/packer
    - user: imgbuilder
    - submodules: True
    - require:
      - file: packer
      - pkg: packer-prereq
  cmd.wait:
    - name: cd $GOPATH/src/github.com/mitchellh/packer; make
    - user: imgbuilder
    - group: imgbuilder
    - watch:
      - git: packer
    - require:
      - file: correct_ip
      - cmd: gox_import
      - cmd: use-old-ssh-until-higebus-branch-is-ready
      - file: go_profile-activate

go_profile:
  file.managed:
    - name: /home/imgbuilder/.profile
    - user: imgbuilder
    - group: imgbuilder

go_profile-activate:
  file.append:
    - name: /home/imgbuilder/.profile
    - text: |
        export GOPATH=/home/imgbuilder/go
        export PATH=${GOPATH}/bin:$PATH
    - require:
      - file: go_profile

correct_ip:
  file.sed:
    - name: /home/imgbuilder/go/src/github.com/mitchellh/packer/builder/qemu/step_type_boot_command.go
    - before: '"127.0.0.1",'
    - after: '"10.0.2.2",'
    - user: imgbuilder
    - require:
      - git: packer

gox_import:
  cmd.run:
    - name: go get -u github.com/mitchellh/gox
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - git: packer
      - file: go_profile-activate

use-old-ssh-until-higebus-branch-is-ready:
  cmd.run:
    - name: cd /home/imgbuilder/go/src/github.com/mitchellh/packer; git pull https://github.com/rasa/packer.git use-old-ssh-until-higebus-branch-is-ready
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - git: packer

packer_templates:
  file.recurse:
    - source: salt://roles/imgbuilder/packer/template
    - name: /mnt/images/templates/packer/
    - user: imgbuilder
    - file_mode: 664
    - dir_mode: 775
    - template: jinja
    - include_empty: True
    - group: libvirtd

box_add_script:
  file.managed:
    - name: /mnt/images/templates/packer/vagrant-box-add.sh
    - mode: 775
    - require:
      - file: packer_templates

