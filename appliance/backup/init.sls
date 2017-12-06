include:
  - appliance.base
  - systemd.reload

/app/.duply/appliance-backup/conf.template:
  file.managed:
    - source: salt://appliance/backup/duply.conf.template
    - makedirs: true
    - require:
      - sls: appliance.base

/app/.duply/appliance-backup/exclude.template:
  file.managed:
    - source: salt://appliance/backup/exclude.template

backup:
  pkg.installed:
    - pkgs:
      - duply
      - duplicity
      - lftp
      - gnupg
      - cifs-utils
      # https://sourceforge.net/projects/pgbarman/

/app/etc/hooks/prepare-appliance/start/backup.sh:
  file.managed:
    - source: salt://appliance/backup/prepare-appliance-start-backup.sh
    - mode: "0755"
    - require:
      - sls: appliance.base

/usr/local/share/appliance/appliance-backup.sh:
  file.managed:
    - source: salt://appliance/backup/appliance-backup.sh
    - mode: "0755"

/usr/local/sbin/recover-from-backup.sh:
  file.managed:
    - source: salt://appliance/backup/recover-from-backup.sh
    - mode: "0755"

/etc/systemd/system/appliance-backup.timer:
  file.managed:
    - source: salt://appliance/backup/appliance-backup.timer
    - watch_in:
      - cmd: systemd_reload

/etc/systemd/system/appliance-backup.service:
  file.managed:
    - source: salt://appliance/backup/appliance-backup.service
    - watch_in:
      - cmd: systemd_reload

enable-appliance-backup-service:
  service.running:
    - name: appliance-backup.timer
    - enable: true
    - require:
      - pkg: backup
      - file: /etc/systemd/system/appliance-backup.service
      - file: /etc/systemd/system/appliance-backup.timer
      - file: /usr/local/share/appliance/appliance-backup.sh
      - file: /app/.duply/appliance-backup/conf.template
      - file: /app/.duply/appliance-backup/exclude.template
    - watch:
      - file: /etc/systemd/system/appliance-backup.service
      - file: /etc/systemd/system/appliance-backup.timer
