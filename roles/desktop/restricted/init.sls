restricted-extras:
  pkg.installed:
    - pkgs:
      - ubuntu-restricted-extras
      - libavcodec-extra
      - libdvdread4

install-css:
  cmd.run:
    - name: /usr/share/doc/libdvdread4/install-css.sh
    - require:
      - pkg: restricted-extras
