{% from "nspawn/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip3_install %}

include:
  - kernel.server
  - python

nspawn:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - uidmap
      - systemd-container
      - libnss-mymachines
      - debspawn
    - require:
      - sls: kernel.server

{# mkosi is bitrotten on focal #}
{{ pip3_install('https://github.com/systemd/mkosi/archive/refs/tags/v9.tar.gz') }}
