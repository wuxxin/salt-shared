include:
  - .python

{% if grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs:
      - unzip
      - zip
      - bzip2
      - cabextract
      {# user tools #}
      - mc    {#  #}
      - jupp    {# user friendly full screen text editor #}
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
      {# other network #}
      - pv        {# monitor the progress of data through a pipe #}
      - socat     {# multipurpose relay for bidirectional data transfer #}
      - netcat    {# TCP/IP swiss army knife #}
      - trickle   {# a lightweight userspace bandwidth shaper #}
      - etherwake {# tool to send magic Wake-on-LAN packets #}
      - httpie    {# CLI, cURL-like tool for humans #}
      - lynx      {# classic non-graphical (text-mode) web browser #}
      - rsync
      - curl
      {# xml, html #}
      - xmlstarlet      {# transform, query, validate, and edit XML #}
      - html-xml-utils  {# manipulating and converting HTML and XML #}
      {# forensic #}
      - ext4magic
      - volatility
      {# conversion #}
      - pff-tools   {# export PAB,PST and OST files (MS Outlook) #}
      
{% endif %}
