{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}


{% if grains['os'] == 'Ubuntu' %}
zfs_ppa:
  pkgrepo.managed:
    - ppa: zfs-native/stable
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
