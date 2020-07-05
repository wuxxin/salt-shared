{% from "email/defaults.jinja" import settings with context %}

{% set dkim_key = salt['pillar.get']('email:dkim:key', false) %}
{% set dkim_enabled = dkim_key != false and
        salt['pillar.get']('email:dkim:enabled', true) %}

{% if dkim_enabled == false %}

opendkim.service:
  service.dead:
    - enable: false
opendkim_masked:
    service.masked:
      - name: opendkim

/etc/dkimkeys/dkim.key:
  file:
    - absent

{% else %}

/etc/opendkim.conf:
  file.managed:
    - source: salt://app/email/opendkim.conf
    - template: jinja
    - defaults:
        domain: {{ salt['pillar.get']('email:domain') }}
        settings: {{ settings }}

/etc/dkimkeys:
  file.directory:
    - user: opendkim
    - group: opendkim
    - mode: "0700"
    - require:
      - user: opendkim

/etc/dkimkeys/dkim.key:
  file.managed:
    - user: opendkim
    - group: opendkim
    - mode: "0600"
    - contents: |
{{ dkim_key |indent(8,True) }}
    - require:
      - file: /etc/dkimkeys
      - user: opendkim

opendkim:
  user.present:
    - name: opendkim
    - shell: /usr/sbin/nologin
    - home: /var/run/opendkim
    - system: True
  pkg.installed:
    - pkgs:
      - opendkim
      - opendkim-tools
    - require:
      - sls: app.network
      - sls: app.ssl

/etc/default/opendkim:
  file.replace:
    - pattern: |
        ^SOCKET=.+
    - repl: |
        SOCKET=inet:12345@localhost
    - append_if_not_found: true
    - require:
      - pkg: opendkim

/etc/systemd/system/opendkim.service.d/onfailure.conf:
  file.managed:
    - makedirs: true
    - contents: |
        [Unit]
        OnFailure=app-service-failed@%n.service

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
      - file: /etc/dkimkeys/dkim.key
      - file: /etc/systemd/system/opendkim.service.d/onfailure.conf

{% endif %}
