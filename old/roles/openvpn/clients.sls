
zip:
  pkg:
    - installed

{% for (client, keyword) in pillar.openvpn_server.clients|dictsort %}

/etc/openvpn/easy-rsa/keys/{{ client }}.key:
  cmd.run:
    - unless: test -f /etc/openvpn/easy-rsa/keys/{{ client }}.key
    - cwd: /etc/openvpn/easy-rsa
    - name: . ./vars; export KEY_CN={{ client }}; ./pkitool --pass {{ keyword }} {{ client }}
    - require:
      - file: /etc/openvpn/server.conf

/etc/openvpn/clients/{{ client }}:
  file.directory:
    - makedirs: True

/etc/openvpn/clients/{{ client }}/openvpn.conf:
  file.managed:
    - source: salt://roles/openvpn/{{ pillar.openvpn_server.mode }}-client.conf
    - template: jinja
    - context:
      server_name: {{ pillar.openvpn_server.name }}
      client_name: {{ client }}
      options: {{ pillar.openvpn_server.options|d([]) }}
    - require:
      - file: /etc/openvpn/clients/{{ client }}
  
files_{{ client }}:
  cmd.run:
    - cwd: /etc/openvpn/easy-rsa/keys
    - name: cp -u ca.crt /etc/openvpn/ta.key {{ client }}.crt {{ client }}.key /etc/openvpn/clients/{{ client }}
    - unless: test -f /etc/openvpn/clients/{{ client }}/{{ client }}.crt
    - require:
      - cmd: /etc/openvpn/easy-rsa/keys/{{ client }}.key
      - file: /etc/openvpn/clients/{{ client }}/openvpn.conf

/etc/openvpn/clients/{{ client }}.zip:
  cmd.run:
    - cwd: /etc/openvpn/clients/{{ client }}
    - unless: test -f /etc/openvpn/clients/{{ client }}.zip
    - name: zip /etc/openvpn/clients/{{ client }}.zip *
    - require:
      - cmd: files_{{ client }}
      - pkg: zip

/etc/openvpn/clients/{{ client }}.zip.gpg:
  cmd.run:
    - unless: test -f /etc/openvpn/clients/{{ client }}.zip.gpg
    - name: gpg --batch --yes --no-tty --no-use-agent --symmetric --passphrase "{{ keyword }}" /etc/openvpn/clients/{{client}}.zip
    - require:
      - cmd: /etc/openvpn/clients/{{ client }}.zip

{% endfor %}

{% if pillar.openvpn_server.revoked|d(false) %}
{% for client in pillar['openvpn_server']['revoked'] %}

revoke_{{ client }}:
  cmd.run:
    - onlyif: test -f /etc/openvpn/easy-rsa/keys/{{ client }}.crt
    - unless: . ./vars; ./is-revoked {{ client }}.crt
    - cwd: /etc/openvpn/easy-rsa
    - name: . ./vars; ./revoke-full {{ client }}
    - require:
      - cmd: /etc/openvpn/easy-rsa/keys/{{ client }}.key
      - file: /etc/openvpn/easy-rsa/is-revoked
      - cmd: /etc/openvpn/crl.pem

{% endfor %}

{% endif %}