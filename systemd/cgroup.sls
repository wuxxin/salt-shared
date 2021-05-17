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
      - cmd: cgroup-reload
{% endfor %}

{# (rootless container) Enabling nonroot user CPU, CPUSET, and I/O delegation #}
/etc/systemd/system/user@.service.d/delegate.conf:
  file.managed:
    - makedirs: true
    - contents: |
        [Service]
        Delegate=cpu cpuset io memory pids
    - onchanges_in:
      - cmd: cgroup-reload

cgroup-reload:
  cmd.run:
    - name: systemctl daemon-reload
