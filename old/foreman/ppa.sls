{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %}

{% if grains['os_family'] == 'Debian' %}
forman_ppa:
  pkgrepo.managed:
    - repo: 'deb http://deb.theforeman.org/ {{ grains['lsb_distrib_codename'] }} stable'
    - key_url: 'http://deb.theforeman.org/pubkey.gpg'
  {% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: ppa_ubuntu_installer
  {% endif %}
{% endif %}

theforeman_nop:
  test:
    - nop
