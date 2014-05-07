dhcp-server:
  pkg:
    - removed
    - name: isc-dhcp-server
  service:
    - dead
    - name: isc-dhcp-server
    - require:
      - pkg: dhcp-server
