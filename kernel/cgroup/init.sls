cgroup:
  pkg.installed:
    - pkgs:
      - cgroup-lite
      {% if grains['osfullname'] == 'ubuntu' and
        grains['osrelease_info'][0] < 16 %}
      - cgroup-bin
      {% else %}
      - cgroup-tools
      {% endif %}

{% if salt['grains.get']('virtual', 'unknown') != 'LXC' %}

{# enable cgroup v2 only hierachy, needs kernel restart #}
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
