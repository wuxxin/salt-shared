{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %}


{% if grains['os_family'] == 'Debian' %}
neurodebian_ppa:
  pkgrepo.managed:
    - name: 'deb http://neurodebian.g-node.org data main contrib non-free'
    - file: /etc/apt/sources.list.d/neurodebian-{{ grains['lsb_distrib_codename'] }}.list
    - keyid: A5D32F012649A5A9
    - keyserver: pgp.mit.edu
  {% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: ppa_ubuntu_installer
  {% endif %}
{% endif %}

neurodebian_nop:
  test:
    - nop