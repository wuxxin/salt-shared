{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}

{% if grains['os_family'] == 'Debian' %}
forman_ppa:
  pkgrepo.managed:
    - repo: 'deb http://deb.theforeman.org/ {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }} stable'
    - key_url: 'http://deb.theforeman.org/pubkey.gpg'
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

