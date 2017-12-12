include:
  - appliance.base

# XXX disable possible leftover from first installation (legacy, could be removed on clean install)
disable_shutdown-unattended-upgrades:
  file.absent:
    - name: /etc/systemd/system/shutdown.target.wants/unattended-upgrades.service
    - watch_in:
      - cmd: systemd_reload

{% for i in ['20auto-upgrades', '50unattended-upgrades',] %}
/etc/apt/apt.conf.d/{{ i }}.ucf-dist:
  file:
    - absent
/etc/apt/apt.conf.d/{{ i }}:
  file.managed:
    - source: salt://appliance/update/{{ i }}
{% endfor %}

system_updates:
  pkg.installed:
    - pkgs:
      - apt
      - update-notifier-common
      - unattended-upgrades

# disable unattended-upgrades from running on shutdown, and via apt-daily service
{% for i in ['apt-daily-upgrade.timer', 'apt-daily-upgrade.service',
  'apt-daily.service', 'apt-daily.timer', 'unattended-upgrades.service'] %}
service_disable_{{ i }}:
  cmd.run:
    - name: systemctl disable {{ i }} || true
    - onlyif: systemctl is-enabled {{ i }}
service_stop_{{ i }}:
  cmd.run:
    - name: systemctl stop {{ i }} || true
    - onlyif: systemctl is-active {{ i }}
/etc/systemd/system/{{ i }}:
  file.symlink:
    - target: /dev/null
    - force: true
    - watch_in:
      - cmd: systemd_reload
{% endfor %}


/usr/local/share/appliance/appliance-update.sh:
  file.managed:
    - source: salt://appliance/update/appliance-update.sh
    - mode: "0755"
    - require:
      - sls: appliance.base

/app/etc/hooks/appliance-prepare/start/update.sh:
  file.managed:
    - source: salt://appliance/update/appliance-prepare-start-update.sh
    - mode: "0755"

/app/etc/hooks/appliance-update/check/00-appliance.sh:
  file.managed:
    - source: salt://appliance/update/check-appliance.sh
    - mode: "0755"

/app/etc/hooks/appliance-update/update/appliance:
  file.managed:
    - source: salt://appliance/update/update-appliance.sh
    - mode: "0755"

/usr/local/share/appliance/update.functions.sh:
  file.managed:
    - source: salt://appliance/update/update.functions.sh

/etc/systemd/system/appliance-update.service:
  file.managed:
    - source: salt://appliance/update/appliance-update.service
    - watch_in:
      - cmd: systemd_reload

/etc/systemd/system/appliance-update.timer.template:
  file.managed:
    - source: salt://appliance/update/appliance-update.timer
    - template: jinja

{% if salt['pillar.get']('appliance:update:automatic', true) %}

/etc/systemd/system/appliance-update.timer:
  file.managed:
    - source: salt://appliance/update/appliance-update.timer
    - template: jinja
    - watch_in:
      - cmd: systemd_reload
  service.running:
    - name: appliance-update.timer
    - enable: true
    - require:
      - file: /usr/local/share/appliance/appliance-update.sh
      - file: /etc/systemd/system/appliance-update.service
      - file: /etc/systemd/system/appliance-update.timer
    - watch:
      - file: /etc/systemd/system/appliance-update.service
      - file: /etc/systemd/system/appliance-update.timer

{% else %}

disable-appliance-update.timer:
  cmd.run:
    - name: systemctl disable appliance-update.timer || true
    - onlyif: systemctl is-enabled appliance-update.timer

stop-appliance-update.timer:
  cmd.run:
    - name: systemctl stop appliance-update.timer || true
    - onlyif: systemctl is-active appliance-update.timer

/etc/systemd/system/appliance-update.timer:
  file.symlink:
    - target: /dev/null
    - force: true
    - watch_in:
      - cmd: systemd_reload

{%- endif %}
