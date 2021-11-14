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
{{ pip3_install('https://github.com/systemd/mkosi/archive/refs/tags/v10.tar.gz') }}

nspawn_config:
  file.directory:
    - name: {{ settings.store.nspawn_config }}
    - makedirs: true
nspawn_volume:
  file.directory:
    - name: {{ settings.store.nspawn_volume }}
    - makedirs: true
nspawn_target:
  file.directory:
    - name: {{ settings.store.nspawn_target }}
    - makedirs: true
mkosi_config:
  file.directory:
    - name: {{ settings.store.mkosi_config }}
    - makedirs: true
mkosi_cache:
  file.directory:
    - name: {{ settings.store.mkosi_cache }}
    - makedirs: true
mkosi_target:
  file.directory:
    - name: {{ settings.store.mkosi_target }}
    - makedirs: true

# systemd-networkd is needed for systemd-nspawn, enable and start systemd-networkd
systemd-networkd:
  service.running:
    - enable: true
