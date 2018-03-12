include:
  - ubuntu

riot:
  pkgrepo.managed:
    - name: deb https://riot.im/packages/debian/ {{ grains['lsb_distrib_codename'] }} main
    - key_url: https://riot.im/packages/debian/repo-key.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: riot
  pkg.installed:
    - name: riot-web

