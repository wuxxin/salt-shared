include:
  - python      {# #}
  - gnupg       {# #}
  - openssl     {# #}
  - unison      {# #}
  - tmux        {# #}
  - .jinja2     {# Jinja2 including cli interface #}
  - .flatyaml   {# #}
  - .raven      {# #}
  - .passgen    {# #}

{% if grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs:
      {# system tools #}
      - gosu
      - git
      - rsync
      - curl
      {# packer/compressor #}
      - bzip2
      - xz-utils
      {# conversion/processor #}
      - sqlite3         {# A command line interface for SQLite version 3 #}
      - jq              {# Command-line JSON processor #}
      - xmlstarlet      {# transform, query, validate, and edit XML #}
      - html-xml-utils  {# manipulating and converting HTML and XML #}
      {# network #}
      - httpie          {# CLI, cURL-like tool for humans #}
      - pv              {# monitor the progress of data through a pipe #}
      - socat           {# multipurpose relay for bidirectional data transfer #}
      - netcat-openbsd  {# TCP/IP swiss army knife #}
      - trickle         {# a lightweight userspace bandwidth shaper #}
      - etherwake       {# tool to send magic Wake-on-LAN packets #}
      - swaks           {# Swiss Army Knife SMTP, all-purpose smtp tester #}
      {# top,perf monitor like #}
      - htop            {#  #}
      - iftop           {#  #}
      - iotop           {#  #}
      - dstat           {# versatile replacement for vmstat, iostat and ifstat #}
      - cpu-checker     {# check cpu features NX/XD and VMX/SVM #}
      - linux-tools-common {# perf-(test, kvm, bench, probe) #}
      - procps          {# watch, free, ps, top, uptime, kill, sysctl, vmstat #}
      - nethogs         {# Net top tool grouping bandwidth per process #}
      - pciutils        {# Linux PCI utilities #}
      - usbutils        {# Linux USB utilities #}
      {# user tools #}
      - mc              {#  #}
      - jupp            {# user friendly full screen text editor #}
      - ncdu            {#  #}
      - tree            {#  #}
      - lynx            {# classic non-graphical (text-mode) web browser #}
      - command-not-found {#  #}
{% endif %}

# utrac: http://www.ubuntuupdates.org/package/getdeb_apps/trusty/apps/getdeb/utrac
