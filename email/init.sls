{% from "email/defaults.jinja" import settings with context %}

include:
  - email.opendkim
  - email.getmail

{% set dkim_key = salt['pillar.get']('email:dkim:key', false) %}
{% set dkim_enabled = dkim_key != false and
        salt['pillar.get']('email:dkim:enabled', true) %}

{%- set relay_host = salt['pillar.get']('email:outgoing:relay:host', false) %}
{%- set relay_port = salt['pillar.get']('email:outgoing:relay:port', 587) %}
{%- set relay_username = salt['pillar.get']('email:outgoing:relay:username', '') %}
{%- set relay_password = salt['pillar.get']('email:outgoing:relay:password', '') %}

{# create /var/mail/root Maildir directory, overwrite in case it is mbox file #}
{%- for v in ['', '/cur', '/new', '/tmp',] %}
/var/mail/root{{ v }}:
  file.directory:
    - force: true
    - dir_mode: "700"
{%- endfor %}

/etc/postfix/main.cf:
  file.managed:
    - source: salt://email/main.cf
    - template: jinja
    - makedirs: true
    - defaults:
        domain: {{ salt['pillar.get']('domain') }}
        settings: {{ settings }}
        dkim_enabled: {{ dkim_enabled }}
        relayhost: {{ relay_host }}
        relayport: {{ relay_port }}
        incoming_enabled: {{ salt['pillar.get']('email:incoming:enabled', true) }}
        outgoing_enabled: {{ salt['pillar.get']('email:outgoing:enabled', true) }}

{# authentification for relayhost, file must exist but can be empty #}
/etc/postfix/sasl_passwd:
  file.managed:
    - contents: |
        # destination= host[:port]      credentials= username:password
{%- if relay_host %}
        [{{ relay_host }}]:{{ relay_port }} {{ relay_username }}:{{ relay_password }}
{% endif %}
  cmd.run:
    - name: postmap /etc/postfix/sasl_passwd
    - onchange:
      - file: /etc/postfix/sasl_passwd
    - require:
      - pkg: postfix
    - require_in:
      - service: postfix

{# set local user aliases, eg. postmaster to root #}
/etc/aliases:
  file.managed:
    - contents: |
{%- for k,v in salt['pillar.get']('email:incoming:aliases', {'postmaster': 'root'}).items() %}
        {{ k }}: {{ v }}
{% endfor %}
  cmd.run:
    - name: postalias /etc/aliases
    - onchange:
      - file: /etc/aliases
    - require:
      - pkg: postfix
    - require_in:
      - service: postfix

postfix:
  pkg.installed:
    - pkgs:
      - postfix
      - mutt
    - require:
      - file: /etc/postfix/main.cf
  service.running:
    - enable: true
    - require:
      - pkg: postfix
      - service: opendkim.service
    - watch:
      - file: /etc/postfix/main.cf
