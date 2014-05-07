ppa_ubuntu_installer:
  pkg.installed:
    - pkgs:
      - python-software-properties
{% if grains['osrelease'] >= '12.10' %}
      - software-properties-common
{% endif %}
    - order: 1


