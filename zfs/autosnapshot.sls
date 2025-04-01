{% from "zfs/defaults.jinja" import settings with context %}

{# 
zfs-auto-snapshot.sh:

- based on: zfsonlinux/zfs-auto-snapshot commit f938d9cc1c414a54a1ee8d638cea7d0ba388ea1a
- changes:
  - PR115: [PATCH] Accept on and off as well as true and false in zfs command outputs
  - PR123: [PATCH] Fix #81 - further snapshots were aborted after the  pre-snapshot command failed once
  - PR124: [PATCH] Use TARGETS_REGULAR if the recursive flag is not set
  - fix opt_verbose
  - reformat with shformat
#}

/usr/local/sbin/zfs-auto-snapshot.sh:
  file.managed:
    - source: salt://zfs/zfs-auto-snapshot.sh
    - mode: "755"

{% for label in ['frequent', 'hourly', 'daily', 'weekly', 'monthly'] %}

zfs-snapshot-{{ label }}.timer:
  file.managed:
    - name: /etc/systemd/system/zfs-snapshot-{{ label }}.timer
    - contents: |
        [Unit]
        Description=ZFS Snapshot Timer ({{ label }})

        [Timer]
        OnCalendar={{ '*:0/15' if label == 'frequent' else label }}
        # Persistent=false - we do not want to remake snapshots if machine was offline
        Persistent=false

        [Install]
        WantedBy=timers.target
    - onchanges_in:
      - cmd: zfs-snapshot-reload-systemd

zfs-snapshot-{{ label }}.service:
  file.managed:
    - name:  /etc/systemd/system/zfs-snapshot-{{ label }}.service
    - contents: |
        [Unit]
        Description=ZFS Snapshot Service ({{ label }})
        Requires=zfs.target
        After=zfs.target
        ConditionPathIsDirectory=/sys/module/zfs

        [Service]
        Type=oneshot
        ExecStart=/usr/local/sbin/zfs-auto-snapshot.sh {{ settings.autosnapshot.args }} --label={{ label }} --keep={{ settings.autosnapshot[label] }} //
    - onchanges_in:
      - cmd: zfs-snapshot-reload-systemd

{% endfor %}

zfs-snapshot-reload-systemd:
  cmd.run:
    - name: systemctl daemon-reload
