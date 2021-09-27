{% from "kernel/defaults.jinja" import settings with context %}

/etc/security/limits.d/maxfiles.conf:
  file.managed:
    - contents: |
        # <domain> <type>  <item>    <value>
        *         soft    nofile    {{ settings.limits.nofile }}
        *         hard    nofile    {{ settings.limits.nofile }}
        root      soft    nofile    {{ settings.limits.nofile }}
        root      hard    nofile    {{ settings.limits.nofile }}
