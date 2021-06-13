{% from "systemd/nspawn/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip3_install %}

include:
  - kernel.server
  - python

nspawn:
  pkg.installed:
    - pkgs:
      - systemd-container
      - libnss-mymachines
      - bridge-utils
      - uidmap
      - debootstrap
      - augeas-tools
    - require:
      - sls: kernel.server

{# mkosi is bitrotten on focal #}
{{ pip3_install('https://github.com/systemd/mkosi/archive/refs/tags/v9.tar.gz') }}


nspawn_env:
  file.directory:
    - name: {{ settings.store.nspawn_env }}
nspawn_config:
  file.directory:
    - name: {{ settings.store.nspawn_config }}
nspawn_volume:
  file.directory:
    - name: {{ settings.store.nspawn_volume }}
nspawn_target:
  file.directory:
    - name: {{ settings.store.nspawn_target }}
mkosi_config:
  file.directory:
    - name: {{ settings.store.mkosi_config }}
mkosi_cache:
  file.directory:
    - name: {{ settings.store.mkosi_cache }}
mkosi_target:
  file.directory:
    - name: {{ settings.store.mkosi_target }}
