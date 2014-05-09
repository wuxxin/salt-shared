include:
  - vagrant
  - roles.imgbuilder.user
  - .dirs
  - .plugins

default_provider:
  file.managed:
    - name: /home/imgbuilder/.profile
    - user: imgbuilder
    - group: imgbuilder
    - require: 
      - cmd: vagrant_plugin_vagrant-libvirt

default_provider-activate:
  file.append:
    - name: /home/imgbuilder/.profile
    - text: |
        export VAGRANT_DEFAULT_PROVIDER=libvirt
    - require:
      - file: default_provider
