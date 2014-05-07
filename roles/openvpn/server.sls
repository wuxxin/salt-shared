openvpn:
  pkg.installed:
    - pkgs:
      - pwgen
      - openssl
      - openvpn
  service.running:
    - require:
      - pkg: openvpn
      - file: /etc/openvpn/server.conf

modify_service:
  cmd.run:
    - unless: test -L /etc/rc2.d/S50openvpn
    - name: update-rc.d -f openvpn remove; update-rc.d openvpn start 50 2 3 4 5 . stop 80 0 1 6 .
    - watch:
      - pkg: openvpn

/etc/openvpn/easy-rsa:
  archive.extracted:
    - name: /etc/openvpn
    - source: salt://roles/openvpn/easy-rsa.tar.gz
    - archive_format: tar
    - tar_options: z
    - if_missing: /etc/openvpn/easy-rsa
    - require:
      - pkg: openvpn

/etc/openvpn/easy-rsa/vars:
  file.managed:
    - source: salt://roles/openvpn/vars
    - template: jinja
    - context:
      key_size: {{ pillar.openvpn_server.ca.key_size|d('2048') }}
      key_expire: {{ pillar.openvpn_server.ca.key_expire|d('3650') }}
      country: {{ pillar.openvpn_server.ca.country }}
      province: {{ pillar.openvpn_server.ca.province }}
      city: {{ pillar.openvpn_server.ca.city }}
      org: {{ pillar.openvpn_server.ca.org }}
      ou:  {{ pillar.openvpn_server.ca.ou }}
      email: {{ pillar.openvpn_server.ca.email }}
      cn: {{ pillar.openvpn_server.ca.cn }}
      ca_name: {{ pillar.openvpn_server.ca.name }}
    - require:
      - archive: /etc/openvpn/easy-rsa

/etc/openvpn/easy-rsa/pkitool:
  file.sed:
    - before: '"" ;;'
    - after: '"-passout pass:$2"; shift ;;'
    - limit: '--pass[ ]+\) NODES_REQ='
    - require:
      - archive: /etc/openvpn/easy-rsa
    - require_in:
      - file: /etc/openvpn/easy-rsa/vars

/etc/openvpn/server.conf:
  file.managed:
    - source: salt://roles/openvpn/{{ pillar.openvpn_server.mode }}-server.conf
    - template: jinja
    - context:
      server_ip:  {{ pillar.openvpn_server.ip }}
      server_name:  {{ pillar.openvpn_server.name }}
      vpn_net:  {{ pillar.openvpn_server.vpn_net }}
      vpn_mask:  {{ pillar.openvpn_server.vpn_mask }}
      dns_ip:  {{ pillar.openvpn_server.dns_ip }}
      dns_domain:  {{ pillar.openvpn_server.dns_domain }}
      ip_routes:  {{ pillar.openvpn_server.ip_routes }}
      options: {{ pillar.openvpn_server.options|d([]) }}

    - require:
      - cmd: /etc/openvpn/ca.crt
      - cmd: /etc/openvpn/ta.key
    - watch_in:
      - service: openvpn

/etc/openvpn/ca.crt:
  cmd.run:
    - unless: test -f /etc/openvpn/ca.crt
    - cwd: /etc/openvpn/easy-rsa/keys
    - name: cp -u ca.crt dh2048.pem {{ pillar.openvpn_server.name }}.crt {{ pillar.openvpn_server.name }}.key /etc/openvpn
    - require:
      - cmd: /etc/openvpn/easy-rsa/keys/ca.crt

/etc/openvpn/easy-rsa/keys/ca.crt:
  cmd.run:
    - unless: test -f /etc/openvpn/easy-rsa/keys/ca.crt
    - user: root
    - cwd: /etc/openvpn/easy-rsa
    - name: . ./vars; ./clean-all; ./pkitool --initca; ./build-dh; ./pkitool --server {{ pillar.openvpn_server.name }}
    - require:
      - file: /etc/openvpn/easy-rsa/vars

/etc/openvpn/ta.key:
  cmd.run:
    - unless: test -f /etc/openvpn/ta.key
    - cwd: /etc/openvpn/easy-rsa
    - name: . ./vars; openvpn --genkey --secret /etc/openvpn/ta.key
    - require:
      - file: /etc/openvpn/easy-rsa/vars
      - cmd: /etc/openvpn/easy-rsa/keys/ca.crt

