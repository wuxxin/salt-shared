
build-from-lp.sh:
  pkg.installed:
    - pkgs:
      - cowbuilder
      - ubuntu-dev-tools
  file.managed:
    - source: salt://ubuntu/build-from-lp.sh
    - name: /usr/local/sbin/build-from-lp.sh
    - mode: "755"
