{% from "email/defaults.jinja" import settings with context %}

{% if not settings.dkim.enabled %}

opendkim.service:
  service.dead:
    - enable: false
opendkim_masked:
    service.masked:
      - name: opendkim

{% else %}

/etc/opendkim.conf:
  file.managed:
    - source: salt://email/opendkim.conf
    - template: jinja
    - defaults:
        settings: {{ settings }}

/etc/dkimkeys:
  file.directory:
    - user: opendkim
    - group: opendkim
    - mode: "0700"
    - require:
      - user: opendkim

{%- for domain, config in settings.dkim.sign.items() %}
/etc/dkimkeys/{{ domain }}_{{ config.selector }}.key:
  file.managed:
    - user: opendkim
    - group: opendkim
    - mode: "0600"
    - contents: |
{{ config.secret|indent(8,True) }}
    - require:
      - file: /etc/dkimkeys
    - watch_in:
      - service: opendkim
{%- endfor %}

/etc/dkimkeys/keytable.txt:
  file.managed:
    - contents: |
{%- for domain, config in settings.dkim.sign.items() %}
        {{ config.selector }}._domainkey.{{ domain }} {{ domain }}:{{ config.selector }}:/etc/dkimkeys/{{ domain }}_{{ config.selector }}.key
{%- endfor %}
    - require:
      - file: /etc/dkimkeys

/etc/dkimkeys/signingtable.txt:
  file.managed:
    - contents: |
{%- for domain, config in settings.dkim.sign.items() %}
        *@{{ domain }} {{ config.selector }}._domainkey.{{ domain }}
{%- endfor %}
    - require:
      - file: /etc/dkimkeys

opendkim:
  user.present:
    - name: opendkim
    - shell: /usr/sbin/nologin
    - home: /run/opendkim
    - system: True
  pkg.installed:
    - pkgs:
      - opendkim
      - opendkim-tools

/etc/default/opendkim:
  file.replace:
    - pattern: |
        ^SOCKET=.+
    - repl: |
        SOCKET={{ settings.dkim.opendkim_listen }}
    - append_if_not_found: true
    - require:
      - pkg: opendkim

opendkim_unmasked:
    service.unmasked:
      - name: opendkim

opendkim.service:
  service.running:
    - name: opendkim
    - enable: true
    - require:
      - pkg: opendkim
    - watch:
      - file: /etc/default/opendkim
      - file: /etc/opendkim.conf
      - file: /etc/dkimkeys/keytable.txt
      - file: /etc/dkimkeys/signingtable.txt

{% endif %}
