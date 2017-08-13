include:
  - .python

{% if grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs:
      - unzip
      - zip
      - cabextract
      {# admin convinience #}
      - mc
      - ncdu
      - tree
      - command-not-found
      {# top,perf like #}
      - htop
      - atop
      - iftop
      - iotop
      - nethogs {# Net top tool grouping bandwidth per process #}
      - blktrace
      - dstat
      - cpu-checker
      - iperf
      - linux-tools-common {# used to get perf #}
      - procps {# used for free #}
      - pciutils
      {# other network #}
      - pv {# monitor the progress of data through a pipe #}
      - socat 
      - netcat
      - trickle {# a lightweight userspace bandwidth shaper #}
      - rsync
      - httpie
      - curl
      - lynx
      - jupp
      - etherwake
      {# xml, html #}
      - sox
      - xmlstarlet
      - html-xml-utils
      {# forensic #}
      - ext4magic
      - volatility
      {# conversion #}
      - pff-tools {# export PAB,PST and OST files (MS Outlook) #}
      
{% endif %}
