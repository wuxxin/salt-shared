dhcp-server:
  pkg:
    - installed
    - name: isc-dhcp-server
  service:
    - running
    - name: isc-dhcp-server
    - require:
      - pkg: dhcp-server
      - file: /etc/default/isc-dhcp-server
      - file: /etc/dhcp/dhcpd.conf

/etc/dhcp/dhcpd.conf:
  file.managed:
    - source: {{ pillar.dhcp_server.data|default('salt://roles/dhcp/dhcpd.conf') }}
    - template: jinja
    - mode: 644
    - watch_in:
      - service: dhcp-server

/etc/default/isc-dhcp-server:
  file.sed:
    - before: '^INTERFACES=""'
    - after: 'INTERFACES="{{ pillar.dhcp_server.interfaces }}"'
    - require:
      - pkg: dhcp-server
    - watch_in:
      - service: dhcp-server

