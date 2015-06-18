{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
zfs_ppa:
  pkgrepo.managed:
    - ppa: zfs-native/stable
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
