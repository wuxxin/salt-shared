
/etc/opendkim.conf:
  file.managed:
    - source: salt://appliance/postfix/opendkim.conf
    - template: jinja
    - defaults:
        domain: {{ salt['pillar.get']('zentyal:domain') }}

/etc/default/opendkim:
  file.managed:
    - contents: |
        # Command-line options specified here will override the contents of
        # /etc/opendkim.conf. See opendkim(8) for a complete list of options.
        #DAEMON_OPTS=""
        #
        SOCKET="inet:12345@localhost"

opendkim:
  pkg.installed:
    - pkgs:
      - opendkim
      - opendkim-tools

{%- set dkimkey= salt['pillar.get']('zentyal:mail:dkim:key', False) or salt['cmd.run_stdout']('openssl genrsa 2048') %}
/etc/dkimkeys/dkim.key:
  file.managed:
    - user: opendkim
    - group: opendkim
    - mode: "0600"
    - makedirs: true
    - contents: |
{{ dkimkey|indent(8,True) }}
    - require:
      - pkg: opendkim

opendkim.service:
  service.running:
    - name: opendkim
    - enable: true
    - require:
      - pkg: opendkim
    - watch:
      - file: /etc/opendkim.conf
      - file: /etc/default/opendkim
      - file: /etc/dkimkeys/dkim.key
