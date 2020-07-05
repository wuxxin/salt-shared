{% from "lxd/defaults.jinja" import settings with context %}

{# lxd is based on lxc #}
include:
  - lxc

lxd:
  file.managed:
    - name: /etc/lxd.yaml
    - contents: |
{%- for section in ['config', 'storage_pools', 'networks', 'profiles', 'projects', 'images', 'certificates'] %}
  {%- if settings[section]|d(false) %}
        {{ section }}:
{{ settings[section]|yaml(false)|indent(10,True) }}
  {% endif %}
{% endfor %}
  pkg.installed:
    - pkgs:
      - lxd
      - lxd-client
      - lxd-tools
    - require:
      - sls: lxc
{% if grains['osrelease_info'][0]|int < 18 or grains['osrelease'] == '18.04' %}
  service.running:
    - enable: True
    - require:
      - pkg: lxd
  cmd.run:
    - name: lxd init --preseed < /etc/lxd.yaml
    - onchanges:
      - file: lxd
    - require:
      - service: lxd
{% else %}
  cmd.run:
    - name: lxd init --preseed < /etc/lxd.yaml
    - onchanges:
      - file: lxd
    - require:
      - pkg: lxd
{% endif %}
