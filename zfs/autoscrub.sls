zpool-scrub@.timer:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub@.timer
    - contents: |
        [Unit]
        Description=ZFS Pool Scrub Timer on %i
  
        [Timer]
        OnCalendar=monthly
        AccuracySec=1h
        Persistent=true

        [Install]
        WantedBy=timers.target
    - require:
      - file: zpool-scrub@.service

zpool-scrub@.service:
  file.managed:
    - name: /etc/systemd/system/zpool-scrub@.service
    - contents: |
        [Unit]
        Description=ZFS Pool Scrub Service on %i, executes once per month for 4 months, then once every 6 months
        Requires=zfs.target
        After=zfs.target
        ConditionACPower=true
        ConditionPathIsDirectory=/sys/module/zfs

        [Service]
        ExecStart=/usr/bin/bash -c \
          'count=$(cat /etc/zfs/zpool-scrub-%I.counter 2>/dev/null || echo 0); \
           if [[ $count -lt 4 || ($count -ge 4 && $((count % 6)) == 0) ]]; then zpool scrub -w %I; fi; \
           echo $((count + 1)) > /etc/zfs/zpool-scrub-%I.counter'

zpool-scrub:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: zpool-scrub@.service
      - file: zpool-scrub@.timer
