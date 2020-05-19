{% from "nfs/defaults.jinja" import settings %}

include:
  - nfs.common

{% macro param_list(param_name, list) %}{% if list %}{{ param_name+ ' '+ list|join(' '+ param_name+ ' ') }}{% endif %}{% endmacro %}
{% set nfs3_option= '' if settings.legacy_support else '-N 3 ' %}
{% set nfs_server_replace = [
  ('RPCNFSDOPTS',   '-N 2 '+ nfs3_option+ '--no-udp '+ param_list('--host', settings.listen_ip) ),
  ('RPCMOUNTDOPTS', '-N 2 '+ nfs3_option+ '--no-udp --manage-gids --port 32767'),
] %}

nfs-kernel-server:
  pkg.installed:
    - require:
      - sls: nfs.common
  service.running:
    - enable: True

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
