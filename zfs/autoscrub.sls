zpool-scrub-initial@.service:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub-initial@.service
    - contents: |
        [Unit]
        Description=ZFS Pool Initial Scrub Series on %i
        Requires=zfs.target
        After=zfs.target
        ConditionACPower=true
        ConditionPathIsDirectory=/sys/module/zfs

        [Service]
        ExecStartPre=-/usr/sbin/zpool scrub -s %I
        ExecStart=/usr/sbin/zpool scrub -w %I

zpool-scrub-resident@.service:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub-resident@.service
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

zpool-scrub-initial@.timer:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub-initial@.timer
    - contents: |
        [Unit]
        Description=ZFS Pool Initial Scrub (8 Weeks every 2nd Sun) on %i

        [Timer]
        OnCalendar=monthly
        AccuracySec=1h
        Persistent=true

        [Install]
        WantedBy=timers.target
    - require:
      - file: zpool-scrub@.service

zpool-scrub-resident@.timer:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub-resident@.timer
    - contents: |
        [Unit]
        Description=ZFS Pool Resident Scrub (every 6 Months on Sun) on %i

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
      - file: zpool-scrub-initial@.service
      - file: zpool-scrub-initial@.timer
      - file: zpool-scrub-resident@.service
      - file: zpool-scrub-resident@.timer
