include:
  - ubuntu

{% if grains['osrelease_info'][0]|int <= 19 %}

riot:
  pkgrepo.managed:
    - name: deb https://riot.im/packages/debian/ {{ grains['lsb_distrib_codename'] }} main
    - key_url: https://riot.im/packages/debian/repo-key.asc
    - file: /etc/apt/sources.list.d/riot.im-debian-main.list
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: riot
  pkg.installed:
    - name: riot-web

{% endif %}
