{% from "node/defaults.jinja" import settings with context %}
{% from "node/lib.sls" import add_internal_bridge %}

{# additional systemd specific nsswitch libraries #}
nsswitch.packages:
  pkg.installed:
    - pkgs:
      - libnss-resolve
      - libnss-mymachines
      - libnss-systemd
      - libnss-myhostname

nsswitch.hosts.configure:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: |
        ^hosts:.+
    - repl: |
        hosts: {{ settings.network.nsswitch.hosts }}
    - append_if_not_found: true

network-utils:
  pkg.installed:
    - pkgs:
      - bridge-utils

{# add internal bridge #}
{{ add_internal_bridge(settings.network.internal.name,
    settings.network.internal.cidr, settings.network.priority) }}


{# write and apply pillar netplan settings to disk if not empty, remove file otherwise #}
default_netplan:
  file:
    - name: /etc/netplan/{{ settings.network.priority }}-default.yaml
{% if not settings.network.netplan %}
    - absent
{% else %}
    - managed
    - contents: |
{{ settings.network.netplan|indent(8,True) }}
{% endif %}
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
      - file: default_netplan

{# write and apply pillar systemd network settings to disk if not empty, remove file otherwise #}
default_systemd.network:
  file:
    - name: /etc/systemd/network/{{ settings.network.priority }}-default.network
  {% if not settings.network.systemd %}
    - absent
{% else %}
    - managed
    - contents: |
{{ settings.network.systemd|indent(8,True) }}
{% endif %}
  cmd.run:
    - name: networkctl reload
    - onchanges:
      - file: default_systemd.network

