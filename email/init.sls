{% from "email/defaults.jinja" import settings with context %}

include:
  - email.opendkim

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
        settings: {{ settings }}

{# authentification for relayhost, file must exist but can be empty #}
/etc/postfix/sasl_passwd:
  file.managed:
    - mode: "0640"
    - contents: |
        # <destination=host[:port]> <credentials=username:password>
{%- if settings.outgoing.relay.enabled %}
        [{{ settings.outgoing.relay.host }}]:{{ settings.outgoing.relay.port }} {{ settings.outgoing.relay.username }}:{{ settings.outgoing.relay.password }}
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
{%- for k,v in settings.aliases.items() %}
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
      - swaks
    - require:
      - file: /etc/postfix/main.cf
  service.running:
    - enable: true
    - require:
      - pkg: postfix
      - service: opendkim.service
    - watch:
      - file: /etc/postfix/main.cf
