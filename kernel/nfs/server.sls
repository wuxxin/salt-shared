{% from "kernel/nfs/defaults.jinja" import settings %}

{% if grains['os'] == 'Manjaro' %}

nfs-kernel-server:
  pkg:
    - installed
  service.running:
    - enable: True

{% elif grains['os'] == 'Ubuntu' %}

include:
  - kernel.nfs.common

{% macro param_list(param_name, list) %}{% if list %}{{ param_name+ ' '+ list|join(' '+ param_name+ ' ') }}{% endif %}{% endmacro %}

{% set nfs_server_replace = [
  ('RPCNFSDOPTS',   '-N 2 -N 3 --no-udp '+ param_list('--host', settings.listen_ip) ),
  ('RPCMOUNTDOPTS', '-N 2 -N 3 --no-udp --manage-gids --port 32767'),
] %}

nfs-kernel-server:
  pkg.installed:
    - require:
      - sls: kernel.nfs.common
  service.running:
    - enable: True
    - require:
      - pkg: nfs-kernel-server

  {% for name, value in nfs_server_replace %}
{{ name }}-nfs-kernel-server:
  file.replace:
    - name: /etc/default/nfs-kernel-server
    - pattern: '^{{ name }}=.*'
    - repl: {{ name }}="{{ value }}"
    - append_if_not_found: true
    - require:
      - pkg: nfs-kernel-server
    - require_in:
      - service: nfs-kernel-server
    - watch_in:
      - service: nfs-kernel-server
  {% endfor %}
{% endif %}
