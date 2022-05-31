include:
  - python              {# basic python environment #}
  - tools.gnupg         {# GnuPG tools for cryptographic communications and data storage #}
  - tools.jinja2cli     {# Jinja templating language cli interface #}
  - tools.flatyaml      {# convert yaml to a flat key=value format #}
  - tools.sentry        {# sentrycat.py error reporting to sentry #}

{% if grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs:

      {# system tools #}
      - gosu            {# alternative to "su" and "sudo" #}
      - git             {# popular version control system #}
      - faketime        {# Report faked system time to programs (cli) #}
      - openssl         {# Secure Sockets Layer toolkit - cryptographic utility #}

      {# compression #}
      - bzip2           {# bzip2 is a patent free, high-quality data compressor #}
      - xz-utils        {# command line tools for working with XZ compression #}
      - zstd            {# Zstandard, is a fast lossless compression algorithm #}

      {# conversion/transformation/querying #}
      - sqlite3         {# A command line interface for SQLite version 3 #}
      - jq              {# Command-line JSON processor #}
      - silversearcher-ag
                        {# ag - fast grep command line tool #}
      - xmlstarlet      {# transform, query, validate, and edit XML #}
      - html-xml-utils  {# manipulating and converting HTML and XML #}
      - html2text       {# converter from HTML to plain text #}
      - tidy            {# convert html to xml #}
      - ssss            {# Shamir's secret sharing scheme implementation #}

      {# network #}
      - curl            {# command line tool for transferring data with URL syntax #}
      - rsync           {# fast, versatile, remote (and local) file-copying tool #}
      - unison          {# crossplatform file-synchronization tool written in OCaml #}
      - httpie          {# CLI, cURL-like tool for humans #}
      - pv              {# monitor the progress of data through a pipe #}
      - socat           {# multipurpose relay for bidirectional data transfer #}
      - netcat-openbsd  {# TCP/IP swiss army knife #}
      - trickle         {# a lightweight userspace bandwidth shaper #}
      - etherwake       {# tool to send magic Wake-on-LAN packets #}
      - swaks           {# Swiss Army Knife SMTP, all-purpose smtp tester #}

      {# top,perf monitor like #}
      - htop            {# ncursed-based process viewer similar to top #}
      - iftop           {# displays bandwidth usage information on an network interface #}
      - iotop           {# displays current I/O usage by processes on the system #}
      - conntrack       {# manage the in-kernel connection tracking state table #}
      - dstat           {# versatile replacement for vmstat, iostat and ifstat #}
      - cpu-checker     {# check cpu features NX/XD and VMX/SVM #}
      - linux-tools-common {# perf-(test, kvm, bench, probe) #}
      - procps          {# watch, free, ps, top, uptime, kill, sysctl, vmstat #}
      - nethogs         {# Net top tool grouping bandwidth per process #}
      - pciutils        {# Linux PCI utilities #}
      - usbutils        {# Linux USB utilities #}

      {# user tools #}
      - tmux            {# terminal multiplexer like screen #}
      - mc              {# Midnight Commander is a text-mode full-screen file manager #}
      - jupp            {# user friendly full screen text editor #}
      - ncdu            {# ncurses-based du viewer #}
      - tree            {# produces a depth indented listing of files #}
      - lynx            {# classic non-graphical (text-mode) web browser #}
      - command-not-found
                        {# a handler that looks up programs not currently installed but available #}
{% endif %}
