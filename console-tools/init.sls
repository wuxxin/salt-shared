
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
      - blktrace
      - dstat
      - cpu-checker
      - iperf
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