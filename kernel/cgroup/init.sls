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

{# enable cgroup memory and swap accounting, needs kernel restart #}
cgroup-grub-settings:
  file.managed:
    - name: /etc/default/grub.d/cgroup.cfg
    - makedirs: true
    - contents: |
        GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX cgroup_enable=memory swapaccount=1"
  cmd.wait:
    - name: update-grub
    - watch:
      - file: cgroup-grub-settings

{% endif %}
