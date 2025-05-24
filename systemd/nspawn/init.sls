{% from "systemd/nspawn/defaults.jinja" import settings with context %}
{% from 'code/python/lib.sls' import pip_install %}

include:
  - systemd.cgroup
  - code.python

{% if grains['os'] == 'Manjaro' %}
nspawn:
  pkg.installed:
    - pkgs:
      - mkosi
      - debootstrap

{% endif %}


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
