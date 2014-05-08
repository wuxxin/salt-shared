
{% if grains['os_family'] == 'Debian' %}
base-deps:
  pkg.installed:
    - pkgs:
      - mc
      - unzip
      - cabextract
      - pv
      - ncdu
      - pwgen
      - command-not-found
      - htop
      - iftop
      - iotop
      - cpu-checker
      - dstat
      - iperf
      - sox 
      - socat
      - netcat
      - nethogs
      - curl
      - links
      - elinks
      - jupp
{% endif %}