
{% macro lxc_volume(name, labels=[], driver='local', opts=[]) %}
{% endmacro %}

{% macro lxc_container(name, template="default", image=none, network=none, storage=none,
    config_head=none, config_custom=none, config_bottom=none) %}

{% load_text as config %}
lxc.uts.name = {{ name }}
# lxc.cgroup2.cpuset.cpus = {# lists the requested CPUs to be used by tasks within this cgroup. eg. 0-4,6,8-10 #}
# lxc.cgroup2.memory.low = memory  {# guaranteed memory in MB. If no value is passed, default is 1024mb #}
# lxc.cgroup2.memory.high = memory
# Init: lxc.init.cmd = init_cmd
# UID/GID mapping
# lxc.idmap = u ns_id host_id entry.count
# Security
# lxc.seccomp.profile =
# lxc.apparmor.profile =
# lxc.autodev = 1
# Process limits
# lxc.prlimit. name = limit.soft limit.hard
# Mounts
# lxc.mount.entry = m.fs m.lxc_mountpoint m.type m.opts
{% endload %}


{% endmacro %}
