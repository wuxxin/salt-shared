zpool-scrub@.service:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub@.service
    - contents: |
        [Unit]
        Description=ZFS Pool Scrub on %i
        Requires=zfs.target
        After=zfs.target
        ConditionACPower=true
        ConditionPathIsDirectory=/sys/module/zfs

        [Service]
        ExecStartPre=-/usr/sbin/zpool scrub -s %I
        ExecStart=/usr/sbin/zpool scrub -w %I

zpool-scrub@.timer:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub@.timer
    - contents: |
        [Unit]
        Description=ZFS Pool Scrub monthly on %i

        [Timer]
        OnCalendar=monthly
        AccuracySec=1h
        Persistent=true

        [Install]
        WantedBy=timers.target
    - require:
      - file: zpool-scrub@.service

  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: zpool-scrub@.service
      - file: zpool-scrub@.timer
