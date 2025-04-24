{% from "node/defaults.jinja" import settings with context %}
{% from "node/lib.sls" import add_internal_bridge %}

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
{{ add_internal_bridge(settings.network.internal.name,settings.network.internal.cidr,
    bridge_type=settings.network.internal.type, priority=settings.network.priority) }}


{% if settings.network.netplan|length > 0 %}
{# write netplan settings from pillar to disk, or delete file if item is empty string #}
  {% for name, data in settings.network.netplan.items() %}
"{{ name }}_netplan":
  file:
    - name: /etc/netplan/{{ name }}
    {% if data == "" %}
    - absent
    {% else %}
    - managed
    - contents: |
{{ data|indent(8,True) }}
    {% endif %}
  {% endfor %}
{# apply changes to netplan if something changed #}
apply_netplan:
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
  {% for name, data in settings.network.netplan.items() %}
      - file: "{{ name }}_netplan"
  {% endfor %}
{% endif %}

{% if settings.network.systemd|length > 0 %}
{# write systemd network settings to from pillar to disk, or delete file if item is empty string #}
  {% for name, data in settings.network.systemd.items() %}
"{{ name }}_systemd_network":
  file:
    - name: /etc/systemd/network/{{ name }}
    {% if data == "" %}
    - absent
    {% else %}
    - managed
    - contents: |
{{ data|indent(8,True) }}
    {% endif %}
  {% endfor %}
{# apply changes to systemd networkd if something changed #}
apply_networkctl_reload:
  cmd.run:
    - name: networkctl reload
    - onchanges:
  {% for name, data in settings.network.systemd.items() %}
      - file: "{{ name }}_systemd_network"
  {% endfor %}
{% endif %}


{% if settings.network.networkmanager|length > 0 %}
stop_networkmanager:
  cmd.run:
    - name: systemctl stop NetworkManager
    - prereq:
  {% for name, data in settings.network.networkmanager.items() %}
      - file: "{{ name }}_networkmanager_nmconnection"
  {% endfor %}    
{# write networkmanager network settings from pillar to disk, or delete file if item is empty string #}
  {% for name, data in settings.network.networkmanager.items() %}
"{{ name }}_networkmanager_nmconnection":
  file:
    - name: /etc/NetworkManager/system-connections/{{ name }}
    {% if data == "" %}
    - absent
    {% else %}
    - managed
    - mode: "0600"
    - contents: |
{{ data|indent(8,True) }}
    {% endif %}
  {% endfor %}
{# restart networkmanager if something changed #}
restart_networkmanager:
  cmd.run:
    - name: systemctl restart NetworkManager
    - onchanges:
  {% for name, data in settings.network.networkmanager.items() %}
      - file: "{{ name }}_networkmanager_nmconnection"
  {% endfor %}
{% endif %}
