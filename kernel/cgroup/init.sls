cgroup:
  pkg.installed:
    - pkgs:
      - cgroup-tools

{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}

{# it's 2020, enable cgroup v2 only hierachy managed by systemd #}
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

{# also, allow normal users setup cgroup v2 recursive userns #}
kernel.unprivileged_userns_clone:
  sysctl.present:
    - value: 1 {# 0 #}

{% endif %}
