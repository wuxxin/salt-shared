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


{{ settings.store.nspawn_env }}:
  file:
    - directory
{{ settings.store.nspawn_config }}:
  file:
    - directory
{{ settings.store.nspawn_volume }}:
  file:
    - directory
{{ settings.store.nspawn_target }}:
  file:
    - directory
{{ settings.store.mkosi_config }}:
  file:
    - directory
{{ settings.store.mkosi_cache }}:
  file:
    - directory
{{ settings.store.mkosi_target }}:
  file:
    - directory
