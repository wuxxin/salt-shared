ppa_ubuntu_installer:
  pkg.installed:
    - pkgs:
{% if grains['osrelease_info'][0]|int <= 18 %}
      - python-software-properties
      - apt-transport-https
{% endif %}
      - software-properties-common
      - update-notifier-common
    - order: 1


{% macro apt_add_repository(statename, ppaname) %}

{{ statename }}:
  pkg.installed:
    - pkgs:
{% if grains['osrelease_info'][0]|int <= 18 %}
      - python-software-properties
      - apt-transport-https
{% endif %}
      - software-properties-common
      - update-notifier-common
  pkgrepo.managed:
    - ppa: {{ ppaname }}
    - file: /etc/apt/sources.list.d/{{ statename }}.list
    - dist: {{ grains['lsb_distrib_codename'] }}
{% if grains['osrelease_info'][0]|int <= 18 %}
    - require:
      - pkg: {{ statename }}
{% endif %}
{%- if kwargs['require_in']|d(None) %}
    - require_in:
  {%- if kwargs['require_in'] is string %}
      - {{ kwargs['require_in'] }}
  {%- else %}
    {%- for i in kwargs['require_in'] %}
      - {{ i }}
    {%- endfor %}
  {%- endif %}
{%- endif %}

{% endmacro %}
