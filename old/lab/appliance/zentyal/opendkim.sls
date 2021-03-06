{% from "old/lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  -  old.lab.appliance.zentyal.base

opendkim:
  pkg.installed:
    - pkgs:
      - opendkim
      - opendkim-tools  
    - require:
      - sls: old.lab.appliance.zentyal.base

{%- set dkimkey= settings.dkim.key or salt['cmd.run_stdout']('openssl genrsa 2048') %}
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

{%- set match = settings.domain|regex_search('[^.]+\.(.+)') %}
{%- set basedomain = match[0] %}
/etc/opendkim.conf:
  file.managed:
    - source: salt://old/lab/appliance/zentyal/files/opendkim.conf
    - template: jinja
    - defaults:
        domain: {{ basedomain }}
    - require:
      - file: /etc/dkimkeys/dkim.key

/etc/default/opendkim:
  file.managed:
    - contents: |
        # Command-line options specified here will override the contents of
        # /etc/opendkim.conf. See opendkim(8) for a complete list of options.
        #DAEMON_OPTS=""
        #
        SOCKET="inet:12345@localhost"
  
    - require:
      - file: /etc/opendkim.conf

opendkim.service:
  service.running:
    - name: opendkim
    - enable: true
    - require:
      - pkg: opendkim
    - onchanges:
      - file: /etc/opendkim.conf
      - file: /etc/default/opendkim
      - file: /etc/dkimkeys/dkim.key
