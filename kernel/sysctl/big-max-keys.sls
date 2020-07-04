{# This is the maximum number of keys a non-root user can use,
  should be higher than the number of containers #}
kernel.keys.maxkeys:
  sysctl.present:
    - value: 2000 {# 200 #}
