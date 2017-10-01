# reload systemd if systemd files changed

systemd_reload:
  cmd.wait:
    - name: systemctl daemon-reload
    - order: last
