zpool-trim@.service:
  file.managed:
    - name:  /etc/systemd/system/zpool-trim@.service
    - contents: |
        [Unit]
        Description=ZFS Pool Trim on %i
        Requires=zfs.target
        After=zfs.target
        ConditionACPower=true
        ConditionPathIsDirectory=/sys/module/zfs

        [Service]
        Nice=19
        IOSchedulingClass=idle
        KillSignal=SIGINT
        ExecStartPre=-zpool trim -c %I
        ExecStart=zpool trim -w %I

zpool-trim@.timer:
  file.managed:
    - name: /etc/systemd/system/zpool-trim@.timer
    - contents: |
        [Unit]
        Description=ZFS Pool Trim monthly on %i

        [Timer]
        OnCalendar=monthly
        AccuracySec=1h
        Persistent=true

        [Install]
        WantedBy=timers.target
    - require:
      - file: zpool-trim@.service

zpool-trim:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: zpool-trim@.service
      - file: zpool-trim@.timer
