include:
  - vagrant
  - imgbuilder

bookie-vm:
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//bookie-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/bookie-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - require:
      - file: /mnt/images/templates/imgbuilder
  cmd.wait:
    - name: cd /mnt/images/templates/imgbuilder/bookie-vm
    - runas: imgbuilder
    - require:
      - file: bookie-vm
      - pkg: vagrant

