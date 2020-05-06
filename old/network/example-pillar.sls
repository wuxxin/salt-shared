network:
  interfaces:
    eth0:
      type: eth
      proto: static
      duplex: full
      dns:
        - 8.8.8.8
      dns-search: in.example.org
      {%- if grains.get('unittest', false) == true %}
      ipaddr: 192.168.2.139
      netmask: 255.255.255.0
      gateway: 192.168.2.1
      pointopoint: 192.168.2.1
      {%- else %}
      ipaddr: 1.2.3.139
      netmask: 255.255.255.255
      pointopoint: 1.2.3.129
      broadcast: 1.2.3.159
      gateway: 1.2.3.129
      {%- endif %}

    resbr0: {# internal resident vm 's network, has routed internal net access #}
      bridge: resbr0
      type: bridge
      ports: none
      proto: static
      ipaddr: 10.9.139.1
      netmask: 255.255.255.0
      broadcast: 10.9.139.255
      stp: off
      maxwait: 0
      fd: 0

    docbr0: {# docker bridge, is handled from docker #}
      bridge: docbr0
      type: bridge
      ports: none
      proto: static
      ipaddr: 10.9.140.1
      netmask: 255.255.255.0
      broadcast: 10.9.140.255
      stp: off
      maxwait: 0
      fd: 0

    isobr0: {# additional vagrant compatible bridge that is isolated from other nets #}
      bridge: isobr0
      type: bridge
      ports: none
      proto: static
      ipaddr: 10.9.141.1
      netmask: 255.255.255.0
      broadcast: 10.9.141.255
      stp: off
      maxwait: 0
      fd: 0

    vpnnet: {# vpn solution uses this net to add clients to the inside nets #}
      type: virtual
      ipaddr: 10.9.142.1
      netmask: 255.255.255.0

    iroutebr0: {# addtional vagrant compatible bridge, that gets routed access to inside nets #}
      bridge: iroutebr0
      type: bridge
      ports: none
      proto: static
      ipaddr: 10.9.143.1
      netmask: 255.255.255.0
      stp: off
      maxwait: 0
      fd: 0

    pubbr0: {# public ip bridge: all ip's in there are public routeable ip's #}
      bridge: pubbr0
      type: bridge
      ports: none
      proto: static
      ipaddr: 1.2.3.139
      netmask: 255.255.255.255
      stp: off
      maxwait: 0
      fd: 0

    virbr1: {# setup for vagrant isolated masquerading bridge, does double nat to outside world #}
      bridge: virbr1
      type: bridge
      ports: none
      proto: static
      {%- if grains.get('unittest', false) == true %}
      ipaddr: 192.168.122.1
      {%- else %}
      ipaddr: 192.168.1.1
      {%- endif %}
      netmask: 255.255.255.0
      stp: off
      maxwait: 0
      fd: 0

  routes:
    pubbr0:
      1.2.3.154:
        netmask: 255.255.255.255
        gateway: 1.2.3.139
      1.2.3.155:
        netmask: 255.255.255.255
        gateway: 1.2.3.139
      1.2.3.156:
        netmask: 255.255.255.255
        gateway: 1.2.3.139
      1.2.3.157:
        netmask: 255.255.255.255
        gateway: 1.2.3.139

  groups:
    masq:
      - resbr0
      - docbr0
      - iroutebr0
      - vpnnet
      - isobr0
      - virbr1
    route:
      - resbr0
      - docbr0
      - iroutebr0
      - vpnnet
      - virbr1
      - pubbr0
    dns:
      - resbr0
      - docbr0
      - iroutebr0
      - vpnnet
      - isobr0
      - virbr1
      - pubbr0
    cache:
      - resbr0
      - docbr0
      - iroutebr0
      - isobr0
      - virbr1
      - pubbr0
