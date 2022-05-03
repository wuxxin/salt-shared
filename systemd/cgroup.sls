{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}
include:
  - kernel.sysctl.cgroup-userns-clone
{% endif %}


{% if grains['os'] == 'Ubuntu' %}
cgroup:
  pkg.installed:
    - pkgs:
      - cgroup-tools
  {% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}
{# it's past 2020, enable cgroup v2 only hierachy managed by systemd #}
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


{% for p in [
  'DefaultCPUAccounting',
  'DefaultIOAccounting',
  'DefaultMemoryAccounting',
  'DefaultTasksAccounting',
  ]
%}
{# enable default Accounting #}
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

{# enabling nonroot user CPU, CPUSET, and I/O delegation for rootless container #}
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
