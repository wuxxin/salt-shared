{% set sys_network = salt['pillar.get']('network:system', {}) %}
{% set interfaces = salt['pillar.get']('network:interfaces', {}) %}
{% set routes = salt['pillar.get']('network:routes', {}) %}

{% if sys_network %}
network-system:
  network.system:
{% for item, data in sys_network.iteritems() %}
    - {{ item }}: {{ data }}{% endfor %}
{% endif %}

{% for item, data in interfaces.iteritems() %}
network-interface-{{ item }}:
  network.managed:
    - name: {{ item }}
{% for sub, subvalue in data.iteritems() %}
    - {{ sub }}: {{ subvalue }}
{% endfor %}
{% endfor %}


{% for interface, data in routes.iteritems() %}
network-route-{{ interface }}:
  file.replace:
    - name: /etc/network/interfaces
    - flags:
      - MULTILINE
      - IGNORECASE
    - bufsize: file
    - pattern: "^iface {{ interface }} inet ([a-z0-9]+)[ ]*$(^[ ]+(up)|(down) ip route .+$)?"
    - repl: "iface {{ interface }} inet \\1\\n{% for ipaddr, subdata in data.iteritems() %}    up  ip route add {{ ipaddr }}/{{ subdata.netmask }} dev {{ interface }}\n    down ip route del {{ ipaddr }}/{{ subdata.netmask }} dev {{ interface }}\n{% endfor %}"

{% endfor %}


FIXME: salt state.network something inserts /etc/init/networking.override with "manual" as data and this fails network setup on boot