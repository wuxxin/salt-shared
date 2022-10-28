{% from "zfs/defaults.jinja" import settings with context %}

{# based on snapshot from commit f938d9cc1c414a54a1ee8d638cea7d0ba388ea1a #}
{# additional changes: reformat with shformat and fix opt_verbose #}
/usr/local/sbin/zfs-auto-snapshot.sh:
  file.managed:
    - source: salt://zfs/zfs-autosnapshot.sh
    - mode: "755"

{% for label in ['frequent', 'hourly', 'daily', 'weekly', 'monthly'] %}

zfs-snapshot-{{ label }}@.timer:
  file.managed:
    - name: /etc/systemd/system/zfs-snapshot-{{ label }}@.timer
    - contents: |
        [Unit]
        Description=ZFS Snapshot Timer ({{ label }}) on %i

        [Timer]
        OnCalendar={{ '*:0/15' if label == 'frequent' else label }}
        # Persistent=false - we do not want to remake snapshots if machine was offline
        Persistent=false

        [Install]
        WantedBy=timers.target

    - onchanges_in:
      - cmd: zfs-snapshot-reload-systemd

zfs-snapshot-{{ label }}@.service:
  file.managed:
    - name:  /etc/systemd/system/zfs-snapshot-{{ label }}@.service
    - contents: |
        [Unit]
        Description=ZFS Snapshot Service ({{ label }}) on %i
        Requires=zfs.target
        After=zfs.target
        ConditionPathIsDirectory=/sys/module/zfs

        [Service]
        Type=oneshot
        ExecStart=/usr/local/sbin/zfs-auto-snapshot.sh {{ settings.snapshot.args }} --label={{ label }} --keep={{ settings.snapshot[label] }} //
    - onchanges_in:
      - cmd: zfs-snapshot-reload-systemd

{% endfor %}

zfs-snapshot-reload-systemd:
  cmd.run:
    - name: systemctl daemon-reload
