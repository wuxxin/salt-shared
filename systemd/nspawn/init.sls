{% from "systemd/nspawn/defaults.jinja" import settings with context %}
{% from 'python/lib.sls' import pip_install %}

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
{{ pip_install('https://github.com/systemd/mkosi/archive/refs/tags/v10.tar.gz') }}

{% for conf in ['nspawn_config', 'nspawn_volume', 'nspawn_target',
  'mkosi_config', 'mkosi_cache', 'mkosi_target'] %}
{{ conf }}:
  file.directory:
    - name: {{ settings.store[conf] }}
    - makedirs: true
{% endfor %}

# systemd-networkd is needed for systemd-nspawn, enable and start systemd-networkd
systemd-networkd:
  service.running:
    - enable: true
