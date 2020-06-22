cgroup:
  pkg.installed:
    - pkgs:
      - cgroup-tools

{% if salt['grains.get']('virtual', 'unknown') != 'LXC' %}

{# it's 2020, enable cgroup v2 only hierachy, needs kernel restart #}
cgroup-grub-settings:
  file.managed:
    - name: /etc/default/grub.d/cgroup.cfg
    - makedirs: true
    - contents: |
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX systemd.unified_cgroup_hierarchy=1"
  cmd.wait:
    - name: update-grub
    - watch:
      - file: cgroup-grub-settings

{% endif %}
