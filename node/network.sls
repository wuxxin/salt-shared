{% from "node/defaults.jinja" import settings %}

include:
  - ssh

{% macro add_internal_bridge(bridge_name, bridge_cidr, priority=80) %}
  {% if salt['cmd.retcode']('which netplan') == 0 %}
bridge_{{ bridge_name }}:
  file.managed:
    - name: /etc/netplan/{{ priority }}-{{ bridge_name }}.yaml
    - makedirs: true
    - contents: |
        network:
          version: 2
          bridges:
            {{ bridge_name}}:
              parameters:
                stp: false
              addresses:
                - {{ bridge_cidr }}
              dhcp4: false
              dhcp6: false
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
      - file: bridge_{{ bridge_name }}

  {% else %}
bridge_{{ bridge_name }}:
  file.managed:
    - name: /etc/network/interfaces.d/{{ priority }}-{{ bridge_name }}.cfg
    - makedirs: true
    - contents: |
        auto {{ bridge_name }}
        iface {{ bridge_name }} inet static
            address {{ bridge_cidr|regex_replace ('([^/]+)/.+', '\\1') }}
            netmask {{ salt['network.convert_cidr'](bridge_cidr)['netmask'] }}
            bridge_fd 0
            bridge_maxwait 0
            bridge_ports none
            bridge_stp off
    - require:
      - pkg: network-utils
  cmd.run:
    - name: ifup {{ bridge_name }}
    - onchanges:
      - file: bridge_{{ bridge_name }}
  {% endif %}
{% endmacro %}

network-utils:
  pkg.installed:
    - pkgs:
      - bridge-utils

{# add resident bridge #}
{{ add_internal_bridge(settings.network.internal_name, settings.network.internal_cidr) }}

nfs.common_after_bridge:
  test.nop:
    - require:
      - cmd: bridge_{{ settings.network.internal_name }}
    - require_in:
      - sls: nfs.common

{# write if not empty, remove if empty #}
default_netplan:
  file:
    - name: /etc/netplan/50-default.yaml
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
    - require_in:
      - sls: nfs.common
