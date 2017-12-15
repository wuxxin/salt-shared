ppa_ubuntu_installer:
  pkg.installed:
    - pkgs:
      - python-software-properties
      - software-properties-common
      - apt-transport-https
    - order: 1

{% macro apt_add_repository(statename, ppaname) %}

{{ statename }}:
  pkg.installed:
    - pkgs:
      - python-software-properties
      - software-properties-common
      - apt-transport-https
  pkgrepo.managed:
    - ppa: {{ ppaname }}
    - file: /etc/apt/sources.list.d/{{ statename }}.list
    - dist: {{ grains['lsb_distrib_codename'] }}
    - require:
      - pkg: {{ statename }}
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
