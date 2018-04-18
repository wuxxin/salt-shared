# reload systemd if systemd files changed

systemd_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - order: last
