ppa_ubuntu_installer:
  pkg.installed:
    - pkgs:
      - python-software-properties
{% if grains['osrelease'] >= '12.10' %}
      - software-properties-common
{% endif %}
      - apt-transport-https

{% macro apt_add_repository(statename, ppaname) %}

{{ statename }}:
  pkgrepo.managed:
    - ppa: {{ ppaname }}
    - file: /etc/apt/sources.list.d/{{ statename }}.list
    - dist: {{ grains['lsb_distrib_codename'] }}
    - require:
      - pkg: ppa_ubuntu_installer
  cmd.run:
    - name: "true"
    - require:
      - pkgrepo: {{ statename }}

{% endmacro %}
