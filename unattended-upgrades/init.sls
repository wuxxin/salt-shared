{% if grains['os_family'] == 'Debian' %}
unattended-upgrades:
  pkg:
    - installed
  file.managed:
    - name: /etc/apt/apt.conf.d/20unattended-upgrades
    - source: salt://unattended-upgrades/unattended-upgrades.cfg
    - mode: 644
    - require:
      - pkg: unattended-upgrades

# remove all nonrunning kernels
# apt-get remove
$(dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | head -n -1)

{% endif %}
