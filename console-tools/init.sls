
{% if grains['os_family'] == 'Debian' %}
base-deps:
  pkg.installed:
    - pkgs:
      - mc
      - unzip
      - zip
      - cabextract
      - ncdu
      - tree
      - command-not-found
      - htop
      - atop
      - iftop
      - iotop
      - blktrace
      - dstat
      - cpu-checker
      - iperf
      - glances
      - linux-tools-common {# used to get perf #}
      - procps {# used for free #}
      - pciutils
      - pv
      - socat
      - netcat
      - nethogs
      - rsync
      - trickle
      - curl
      - elinks
      - links
      - jupp
      - sox
      - xmlstarlet
      - html-xml-utils
      - etherwake
      - httpie

{% endif %}
