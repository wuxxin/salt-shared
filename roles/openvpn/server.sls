{% set key_size= pillar.openvpn_server.ca.key_size|d('2560') %}
{% set key_expire= pillar.openvpn_server.ca.key_expire|d('3650') %}

openvpn:
  pkg.installed:
    - pkgs:
      - pwgen
      - openssl
      - openvpn
  service.running:
    - enable: true
    - require:
      - pkg: openvpn
      - cmd: modify_service
    - watch:
      - file: /etc/openvpn/server.conf

modify_service:
  cmd.run:
    - unless: test -L /etc/rc2.d/S50openvpn
    - name: update-rc.d -f openvpn remove; update-rc.d openvpn start 50 2 3 4 5 . stop 80 0 1 6 .
    - require:
      - pkg: openvpn

/etc/openvpn/easy-rsa:
  archive.extracted:
    - name: /etc/openvpn
    - source: salt://roles/openvpn/easy-rsa.tar.gz
    - archive_format: tar
    - tar_options: ax
    - if_missing: /etc/openvpn/easy-rsa
    - require:
      - pkg: openvpn

/etc/openvpn/easy-rsa/pkitool:
  file.sed:
    - before: '"" ;;'
    - after: '"-passout pass:$2"; shift ;;'
    - limit: '--pass[ ]+\) NODES_REQ='
    - require:
      - archive: /etc/openvpn/easy-rsa

/etc/openvpn/easy-rsa/is-revoked:
  file.managed:
    - source: salt://roles/openvpn/is-revoked
    - mode: 775
    - require:
      - archive: /etc/openvpn/easy-rsa

/etc/openvpn/easy-rsa/vars:
  file.managed:
    - source: salt://roles/openvpn/vars
    - template: jinja
    - context:
      key_size: {{ key_size }}
      key_expire: {{ key_expire }}
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
      - file: /etc/openvpn/easy-rsa/pkitool
      - file: /etc/openvpn/easy-rsa/is-revoked

{% for n, c in (
("ca.crt", "./clean-all; ./pkitool --initca"),
(pillar.openvpn_server.name+ ".crt", "./pkitool --server "+ pillar.openvpn_server.name),
("dh"+ key_size+ ".pem", "./build-dh"),
("ta.key", "openvpn --genkey --secret /etc/openvpn/keys/ta.key"),
("crl.pem", "cd $KEY_DIR; $OPENSSL ca -gencrl -crldays "+ key_expire+ " -out crl.pem -config $KEY_CONFIG")
) %}

/etc/openvpn/easy-rsa/keys/{{ n }}:
  cmd.run:
    - unless: test -f /etc/openvpn/easy-rsa/keys/{{ n }}
    - user: root
    - cwd: /etc/openvpn/easy-rsa
    - name: . ./vars; {{ c }}
    - require:
      - file: /etc/openvpn/easy-rsa/vars

/etc/openvpn/{{ n }}:
  cmd.run:
    - cwd: /etc/openvpn/easy-rsa/keys
    - name: cp -u {{ n }} /etc/openvpn/
    - onlyif: test {{ n }} -nt /etc/openvpn/{{ n }}
    - require:
      - cmd: /etc/openvpn/easy-rsa/keys/{{ n }}
    - require_in:
      - file: /etc/openvpn/server.conf

{% endfor %}

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
      key_size: {{ key_size }}
      key_expire: {{ key_expire }}
