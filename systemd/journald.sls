{% for p,r in [
  ("SystemMaxUse", "SystemMaxUse=128M")
  ("RuntimeMaxUse", "RuntimeMaxUse=64M"),
  ] %}

/etc/systemd/journald.conf_{{ p }}:
  file.replace:
    - name: /etc/systemd/journald.conf
    - pattern: |
        ^{{ p }}.*
    - repl: |
        {{ r }}
    - append_if_not_found: true
{% endfor %}

/etc/systemd/journald.conf:
  cmd.run:
    - name: systemctl restart systemd-journald
    - onchanges:
      - file: /etc/systemd/journald.conf
