{% if grains['virtual']|lower() not in ['lxc', 'systemd-nspawn'] %}

{# allow normal users setup cgroup v2 recursive userns #}
kernel.unprivileged_userns_clone:
  sysctl.present:
    - value: 1 {# 0 #}

{% endif %}
