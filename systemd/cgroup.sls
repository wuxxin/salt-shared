# allow normal users setup cgroup v2 recursive userns
{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}
include:
  - kernel.sysctl.cgroup-userns-clone
{% endif %}

# enable systemd accounting for limits
{% for p in ['DefaultCPUAccounting', 'DefaultIOAccounting','DefaultMemoryAccounting', 'DefaultTasksAccounting'] %}
/etc/systemd/system.conf_{{ p }}:
  file.replace:
    - name: /etc/systemd/system.conf
    - pattern: |
        ^{{ p }}.*
    - repl: |
        {{ p }}=True
    - append_if_not_found: true
    - onchanges_in:
      - cmd: systemd-reload-for-cgroup
{% endfor %}

# enable nonroot user CPU, CPUSET, and I/O delegation for rootless container
/etc/systemd/system/user@.service.d/delegate.conf:
  file.managed:
    - makedirs: true
    - contents: |
        [Service]
        Delegate=cpu cpuset io memory pids
    - onchanges_in:
      - cmd: systemd-reload-for-cgroup
  
systemd-reload-for-cgroup:
  cmd.run:
    - name: systemctl daemon-reload

