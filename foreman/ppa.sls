{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}


{% if grains['os'] == 'Ubuntu' or grains['os'] == 'Debian' %}
forman_ppa:
  pkgrepo.managed:
    - repo: 'deb http://deb.theforeman.org/ {{ grains['lsb_distrib_codename'] }} stable'
    - key_url: 'http://deb.theforeman.org/pubkey.gpg'
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}

