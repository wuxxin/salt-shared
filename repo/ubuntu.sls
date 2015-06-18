ppa_ubuntu_installer:
  pkg.installed:
    - pkgs:
      - python-software-properties
{% if grains['osrelease'] >= '12.10' %}
      - software-properties-common
{% endif %}
    - order: 1

{% macro apt_add_repository(statename, ppaname) %}

{{ statename }}:
{% if grains['os'] == 'Mint' %}
  cmd.run:
    - name: apt-add-repository -y ppa:{{ ppaname }}
    - unless: test -f /etc/apt/sources.list.d/{{ salt['extutils.re_replace']("[/.]","*", ppaname) }}-trusty.list
    - require:
      - pkg: ppa_ubuntu_installer
{% else %}
  pkgrepo.managed:
    - ppa: {{ ppaname }}
    - file: /etc/apt/sources.list.d/{{ statename }}.list
    - dist: {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }}
    - require:
      - pkg: ppa_ubuntu_installer
  cmd.run:
    - name: true
    - require:
      - pkgrepo: {{ statename }}
{% endif %}

{% endmacro %}
