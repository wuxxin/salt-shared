include:
  - vagrant
  - roles.imgbuilder.user

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

vagrant_plugin_deps:
  pkg.installed:
    - pkgs:
      - libxslt1-dev
      - libxml2-dev
      - zlib1g-dev
      - libvirt-dev
      - qemu-utils
    - require:
      - pkg: vagrant


{% for t in ["vagrant-libvirt", "sahara", "vagrant-cachier", "vagrant-omnibus", "vagrant-mutate", 
"vagrant-bindfs", "vagrant-windows", "docker-provider", "gusteau"] %}

vagrant_plugin_{{ t }}:
  cmd.run:
    - name: vagrant plugin install {{ t }} 
    - unless: vagrant plugin list | grep -q {{ t }}
    - user: imgbuilder
    - require:
      - pkg: vagrant
      - pkg: vagrant_plugin_deps

{% endfor %}

#vagrant_plugin_vagrant-berkshelf:
#  cmd.run:
#    - name: vagrant plugin install vagrant-berkshelf --plugin-version 2.0.0.rc3
#    - unless: vagrant plugin list | grep -q vagrant-berkshelf
#    - user: imgbuilder
#    - require:
#      - pkg: vagrant
#      - pkg: vagrant_plugin_deps


default_provider:
  file.managed:
    - name: /home/imgbuilder/.bash_profile
    - user: imgbuilder
    - group: imgbuilder
    - require: 
      - cmd: vagrant_plugin_vagrant-libvirt

default_provider-activate:
  file.append:
    - name: /home/imgbuilder/.bash_profile
    - text: |
        export VAGRANT_DEFAULT_PROVIDER=libvirt
    - require:
      - file: default_provider
