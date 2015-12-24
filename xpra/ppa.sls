{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}


{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
xpra_ppa:
  pkgrepo.managed:
    - name: deb https://www.xpra.org/dists/ {{ grains['lsb_distrib_codename'] if grains['os'] != 'Mint' else 'trusty' }} main
    - file: /etc/apt/sources.list.d/xpra.list
    - keyurl: "salt://xpra/gpg.asc"
    - require:
      - pkg: ppa_ubuntu_installer
{% endif %}
