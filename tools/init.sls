include:
  - python
  - .flatyaml
  - .raven
  - .qrcode

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('percol') }} {# interactive pipe filtering #}

{% if grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs:
      {# system tools #}
      - gosu
      - git
      - rsync
      - curl
      - wget
      {# user tools #}
      - mc    {#  #}
      - jupp  {# user friendly full screen text editor #}
      - ncdu  {#  #}
      - tree  {#  #}
      - command-not-found {#  #}
      {# top,perf monitor like #}
      - htop  {#  #}
      - atop  {#  #}
      - iftop {#  #}
      - iotop {#  #}
      - blktrace    {# block layer IO tracing mechanism #}
      - dstat       {# versatile replacement for vmstat, iostat and ifstat #}
      - cpu-checker {# check cpu features NX/XD and VMX/SVM #}
      - iperf       {# Internet Protocol bandwidth measuring tool #}
      - linux-tools-common {# perf-(test, kvm, bench, probe) #}
      - procps      {# watch, free, ps, top, uptime, kill, sysctl, vmstat #}
      - nethogs     {# Net top tool grouping bandwidth per process #}
      - pciutils    {# Linux PCI utilities #}
      - usbutils    {# Linux USB utilities #}
      {# network #}
      - pv        {# monitor the progress of data through a pipe #}
      - socat     {# multipurpose relay for bidirectional data transfer #}
      - netcat    {# TCP/IP swiss army knife #}
      - trickle   {# a lightweight userspace bandwidth shaper #}
      - etherwake {# tool to send magic Wake-on-LAN packets #}
      - httpie    {# CLI, cURL-like tool for humans #}
      - lynx      {# classic non-graphical (text-mode) web browser #}
      - swaks     {# Swiss Army Knife SMTP, all-purpose smtp tester #}
      {# forensic #}
      - ext4magic
      - volatility
      {# packer/compressor #}
      - bzip2
      - cabextract
      {# conversion/processor #}
      - sqlite3         {# A command line interface for SQLite version 3 #}
      - jq              {# Command-line JSON processor #}
      - xmlstarlet      {# transform, query, validate, and edit XML #}
      - html-xml-utils  {# manipulating and converting HTML and XML #}
      - pff-tools       {# export PAB,PST and OST files (MS Outlook) #}
  
{% endif %}
