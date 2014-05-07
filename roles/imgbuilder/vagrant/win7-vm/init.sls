include:
  - vagrant
  - imgbuilder

win7-vm:
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//win7-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/win7-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - require:
      - file: /mnt/images/templates/imgbuilder
