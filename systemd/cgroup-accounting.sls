{% for p in [
  'DefaultCPUAccounting',
  'DefaultIOAccounting',
  'DefaultMemoryAccounting',
  'DefaultTasksAccounting',
  ]
%}

/etc/systemd/system.conf_{{ p }}:
    file.replace:
    - name: /etc/systemd/system.conf
    - pattern: |
        ^{{ p }}.*
    - repl: |
        {{ p }}=True
    - append_if_not_found: true
    - onchanges_in:
      cmd: cgroup-accounting-reload
{% endfor %}

cgroup-accounting-reload:
  cmd.run:
    - name: systemctl daemon-reload
