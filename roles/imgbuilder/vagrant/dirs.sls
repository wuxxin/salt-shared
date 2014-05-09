
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

default_provider_create:
  file.managed:
    - name: /home/imgbuilder/.profile
    - user: imgbuilder
    - group: imgbuilder
    - require: 
      - cmd: vagrant_plugin_vagrant-libvirt

default_provider:
  file.append:
    - name: /home/imgbuilder/.profile
    - text: |
        export VAGRANT_DEFAULT_PROVIDER=libvirt
    - require:
      - file: default_provider_create
