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
              interfaces: []
              parameters:
                stp: false
                forward-delay: 0
              addresses:
                - {{ bridge_cidr }}
              dhcp4: false
              dhcp6: false
              link-local: []
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
      - file: bridge_{{ bridge_name }}

{% elif salt['cmd.retcode']('systemctl is-enabled systemd-networkd') == 0 %}
bridge_{{ bridge_name }}_netdev:
  file.managed:
    - name: /etc/systemd/network/{{ priority }}-{{ bridge_name }}.netdev
    - makedirs: true
    - contents: |
        [NetDev]
        Name={{ bridge_name }}
        Kind=bridge

        [Bridge]
        STP=false
bridge_{{ bridge_name }}:
  file.managed:
    - name: /etc/systemd/network/{{ priority }}-{{ bridge_name }}.network
    - makedirs: true
    - contents: |
        [Match]
        Name={{ bridge_name }}

        [Network]
        LinkLocalAddressing=ipv6
        Address={{ settings.bridge_cidr }}
        ConfigureWithoutCarrier=yes
  cmd.run:
    - name: networkctl reload
    - onchanges:
      - file: bridge_{{ bridge_name }}_netdev
      - file: bridge_{{ bridge_name }}

  {% else %}
bridge_{{ bridge_name }}:
  file.managed:
    - name: /etc/network/interfaces.d/{{ bridge_name }}.cfg
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
