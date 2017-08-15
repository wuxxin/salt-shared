{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %}


{% if grains['os_family'] == 'Debian' %}
aptly_ppa:
  pkgrepo.managed:
    - repo: 'deb http://repo.aptly.info/ squeeze main'
    - file: /etc/apt/sources.list.d/aptly-main-trusty.list
    - keyid: E083A3782A194991
    - keyserver: keys.gnupg.net
  {% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: ppa_ubuntu_installer
  {% endif %}
{% endif %}

aptly_nop:
  test:
    - nop
