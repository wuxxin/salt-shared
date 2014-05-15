
{% if grains['os_family'] == 'Debian' %}
base-deps:
  pkg.installed:
    - pkgs:
      - mc
      - unzip
      - zip
      - cabextract
      - pv
      - ncdu
      - pwgen
      - command-not-found
      - htop
      - iftop
      - iotop
      - dstat
      - cpu-checker
      - iperf
      - hwinfo
      - pciutils
      - socat
      - netcat
      - nethogs
      - curl
      - links
      - elinks
      - jupp
      - sox

{% endif %}