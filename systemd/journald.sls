
# journald: triple the default RateLimitBurst, startup is usually more noisy
{% for p,r in [
  ("RateLimitBurst", "RateLimitBurst=3000"),
  ] %}

{#
# journald: do not forward to syslog for storing, because we let journald store on disk
("ForwardToSyslog", "ForwardToSyslog=No"),
("Storage", "Storage=persistent"),
#}

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
