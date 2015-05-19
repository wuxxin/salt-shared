include:
  - roles.imgbuilder.user

{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

/home/{{ s.user }}/.vagrant.d:
  file.directory:
    - user: {{ s.user }}
    - group: {{ s.user }}
    - require:
      - user: imgbuilder

{{ s.image_base }}/templates/vagrant:
  file.directory:
    - user: {{ s.user }}
    - group: libvirtd
    - mode: 775
    - makedirs: True
    - require:
      - file: /home/{{ s.user }}/.vagrant.d

/home/{{ s.user }}/.vagrant.d/boxes:
  file.symlink:
    - target: {{ s.image_base }}/templates/vagrant
    - require:
      - file: {{ s.image_base }}/templates/vagrant

/home/{{ s.user }}/.vagrant.d/tmp:
  file.symlink:
    - target: {{ s.image_base }}/tmp
    - require:
      - file: /home/{{ s.user }}/.vagrant.d

default_provider_create:
  file.managed:
    - name: /home/{{ s.user }}/.profile
    - user: {{ s.user }}
    - group: {{ s.user }}
    - require: 
      - cmd: vagrant_plugin_vagrant-libvirt

default_provider:
  file.append:
    - name: /home/{{ s.user }}/.profile
    - text: |
        export VAGRANT_DEFAULT_PROVIDER=libvirt
    - require:
      - file: default_provider_create
