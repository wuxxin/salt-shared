
/home/imgbuilder/.vagrant.d:
  file.directory:
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - user: imgbuilder

/mnt/images/templates/vagrant:
  file.directory:
    - user: imgbuilder
    - group: libvirtd
    - mode: 775
    - makedirs: True
    - require:
      - file: /home/imgbuilder/.vagrant.d

/home/imgbuilder/.vagrant.d/boxes:
  file.symlink:
    - target: /mnt/images/templates/vagrant
    - require:
      - file: /mnt/images/templates/vagrant

/home/imgbuilder/.vagrant.d/tmp:
  file.symlink:
    - target: /mnt/images/tmp
    - require:
      - file: /home/imgbuilder/.vagrant.d

