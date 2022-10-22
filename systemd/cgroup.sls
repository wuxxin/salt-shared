{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}
{# allow normal users setup cgroup v2 recursive userns #}
include:
  - kernel.sysctl.cgroup-userns-clone
{% endif %}

{% for p in 
  ['DefaultCPUAccounting', 'DefaultIOAccounting','DefaultMemoryAccounting', 'DefaultTasksAccounting']
%}
{# enable systemd accounting for limits #}
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

{# enabling nonroot user CPU, CPUSET, and I/O delegation for rootless container #}
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


{% if grains['os'] == 'Ubuntu' %}
cgroup:
  pkg.installed:
    - pkgs:
      - cgroup-tools
  {% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}
cgroup-grub-settings:
  file.managed:
    - name: /etc/default/grub.d/cgroup.cfg
    - makedirs: true
    - contents: |
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX swapaccount=1 systemd.unified_cgroup_hierarchy=1"
  cmd.wait:
    - name: update-grub
    - watch:
      - file: cgroup-grub-settings
  {% endif %}
{% endif %}
