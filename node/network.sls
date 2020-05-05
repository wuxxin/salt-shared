{% from "node/defaults.jinja" import settings %}

include:
  - .hostname

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
{{ add_internal_bridge(settings.bridge_name, settings.bridge_cidr) }}

{# write possible different to recovery netplan #}
/etc/netplan/50-lan.yaml:
  file.managed:
    - contents: |
{{ settings.netplan_default|indent(8,True) }}
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
      - file: /etc/netplan/50-lan.yaml

{# restrict rpcbind to localhost and default list ([bridge_ip]) #}
/etc/default/rpcbind:
  file.replace:
    - pattern: "^OPTIONS=.+"
    - repl: OPTIONS="-w -l -h 127.0.0.1 -h ::1 {% for ip in settings.rpcbind %}-h {{ ip }}{% endfor %}
    - append_if_not_found: true
  service.running:
    - name: rpcbind
    - enable: True
    - require:
      - pkg: network-utils
    - watch:
      - file: /etc/default/rpcbind

/etc/systemd/system/rpcbind.socket:
  file.managed:
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
{%- for ip in settings.rpcbind %}
        ListenStream={{ ip }}:111
        ListenDatagram={{ ip }}:111
{%- endfor %}
        [Install]
        WantedBy=sockets.target
  cmd.run:
    - name: systemctl daemon-reload
    - order: last
    - onchanges:
      - file: /etc/systemd/system/rpcbind.socket
  service.running:
    - name: rpcbind.socket
    - enable: True
    - require:
      - pkg: network-utils
      - cmd: /etc/systemd/system/rpcbind.socket
    - watch:
      - file: /etc/systemd/system/rpcbind.socket
