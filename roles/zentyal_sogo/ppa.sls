{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
sogo_ppa_ubuntu:
  pkgrepo.managed:
    - name: deb http://inverse.ca/ubuntu {{ grains['lsb_distrib_codename'] }} {{ grains['lsb_distrib_codename'] }}
    - humanname: "Inverse Sogo Server Repository"
    - file: /etc/apt/sources.list.d/inverse-sogo-{{ grains['lsb_distrib_codename'] }}.list
    - keyid: 0x810273c4
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
