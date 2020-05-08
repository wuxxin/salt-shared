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
      - nfs-common
      - rpcbind

{# add resident bridge #}
{{ add_internal_bridge(settings.network.internal_name, settings.network.internal_cidr) }}

{# write if not empty, remove if empty #}
/etc/netplan/50-default.yaml:
{% if not settings.network.netplan %}
  file:
    - absent
{% else %}
  file.managed:
    - contents: |
{{ settings.network.netplan|indent(8,True) }}
{% endif %}
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
      - file: /etc/netplan/50-default.yaml
    - require_in:
      - service: rpcbind
      - service: rpcbind.socket

{# restrict rpcbind to localhost and default list ([internal_ip]) #}
rpcbind:
  file.replace:
    - name: /etc/default/rpcbind
    - pattern: '^OPTIONS=".+"'
    - repl: OPTIONS="-w -l -h 127.0.0.1 -h ::1 {% for ip in settings.network.rpc_bind_list %}-h {{ ip }}{% endfor %}"
    - append_if_not_found: true
  service.running:
    - name: rpcbind
    - enable: True
    - require:
      - pkg: network-utils
      - cmd: bridge_{{ settings.network.internal_name }}
    - watch:
      - file: rpcbind

rpcbind.socket:
  file.managed:
    - name: /etc/systemd/system/rpcbind.socket
    - makedirs: true
    - contents: |
        [Unit]
        Description=RPCbind Server Activation Socket
        DefaultDependencies=no
        After=network-online.target

        [Socket]
        ListenStream=/run/rpcbind.sock

        # RPC netconfig can't handle ipv6/ipv4 dual sockets
        BindIPv6Only=ipv6-only
        ListenStream=127.0.0.1:111
        ListenDatagram=127.0.0.1:111
        ListenStream=[::1]:111
        ListenDatagram=[::1]:111
{%- for ip in settings.network.rpc_bind_list %}
        ListenStream={{ ip }}:111
        ListenDatagram={{ ip }}:111
{%- endfor %}
        [Install]
        WantedBy=sockets.target
  cmd.run:
    - name: systemctl daemon-reload
    - order: last
    - onchanges:
      - file: rpcbind.socket
  service.running:
    - name: rpcbind.socket
    - enable: True
    - require:
      - pkg: network-utils
      - cmd: rpcbind.socket
      - cmd: bridge_{{ settings.network.internal_name }}
    - watch:
      - file: rpcbind.socket
