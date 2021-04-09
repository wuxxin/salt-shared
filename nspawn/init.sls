{% from "nspawn/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip3_install %}

include:
  - kernel.server
  - python

nspawn:
  pkg.installed:
    - pkgs:
      - thin-provisioning-tools
      - bridge-utils
      - ebtables
      - uidmap
      - systemd-container
      - libnss-mymachines
    - require:
      - sls: kernel.server

nspawn_tools:
  pkg.installed:
    - pkgs:
      - debspawn
      - open-infrastructure-container-tools
    - require:
      - pkg: nspawn

{# mkosi is bitrotten on focal #}
{{ pip3_install('https://github.com/systemd/mkosi/archive/refs/tags/v9.tar.gz') }}
