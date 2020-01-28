include:
  - python      {# #}
  - gnupg       {# #}
  - openssl     {# #}
  - unison      {# #}
  - tmux        {# #}
  - .jinja2     {# Jinja2 including cli interface #}
  - .flatyaml   {# convert yaml to a flat key=value format #}
  - .sentry     {# sentrycat.py error reporting to sentry #}
  - .passgen    {# human friendly passwort generator #}


{% if grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs:
      {# system tools #}
      - gosu
      - git
      - faketime        {# Report faked system time to programs (cli) #}
      {# compression #}
      - bzip2           {# bzip2 is a patent free, high-quality data compressor #}
      - xz-utils        {# command line tools for working with XZ compression #}
      {# conversion/transformation/querying #}
      - sqlite3         {# A command line interface for SQLite version 3 #}
      - jq              {# Command-line JSON processor #}
      - xmlstarlet      {# transform, query, validate, and edit XML #}
      - html-xml-utils  {# manipulating and converting HTML and XML #}
      - html2text       {# converter from HTML to plain text #}
      - ssss            {# Shamir's secret sharing scheme implementation #}
      {# network #}
      - curl            {# command line tool for transferring data with URL syntax #}
      - rsync           {# fast, versatile, remote (and local) file-copying tool #}
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
      - conntrack       {# manage the in-kernel connection tracking state table #}
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
