# ### postfix

{% if salt['pillar.get']('zentyal:mail:status', "absent") == "present" %}

/etc/zentyal/hooks/mail.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/mail/mail.postsetconf
    - mode: 755
    - require:
      - pkg: zentyal

{% for filename, pillaritem in 
  ('tls_policy', 'zentyal:mail:tls_policy'),
  ('generic_outgoing', 'zentyal:mail:rewrite'),
  ('recipient_bcc', 'zentyal:mail:incoming_bcc'),
  ('sender_bcc', 'zentyal:mail:outgoing_bcc'),
  ('custom_transport', 'zentyal:mail:transport') %}

/etc/postfix/{{ filename }}:
  file.managed:
    - source: salt://roles/zentyal/mail/key_seperator_value.jinja
    - template: jinja
    - context:
        dataset: {{ salt['pillar.get'](pillaritem, ' ') }}
    - require:
      - pkg: zentyal
  cmd.run:
    - name: postmap /etc/postfix/{{ filename }}
    - watch:
       - file: /etc/postfix/{{ filename }}

{% endfor %}


# ### dovecot

/usr/local/lib/dovecot-lda-year-append:
  file.managed:
    - source: salt://roles/zentyal/mail/dovecot-lda-year-append
    - mode: 755
    - require:
      - pkg: zentyal

/usr/local/lib/dovecot-lda:
  file.managed:
    - source: salt://roles/zentyal/mail/dovecot-lda
    - mode: 755
    - require:
      - pkg: zentyal

/etc/dovecot/extra.conf:
  file.managed:
    - source: salt://roles/zentyal/mail/extra.conf
    - require:
      - pkg: zentyal


# todo:

# create mailboxes 
# doveadm mailbox create public.incoming.2012 -u postmaster@spitzauer.at
# doveadm mailbox create public.sent.2012 -u postmaster@spitzauer.at

# create sieve of postmaster@spitzauer.at
## rule:[delete_from_to_same]
#if allof (not header :contains "To" "postmaster_public/incoming@spitzauer.at", not header :contains "To" "postmaster_public/sent@spitzauer.at", header :contains "To" "spitzauer.at", header :contains "From" "spitzauer.at")
#{
#        discard;
#        stop;
#}


# ### fetchmail

/etc/default/fetchmail:
  file.sed:
    - before: '^START_DAEMON=no'
    - after: 'START_DAEMON=yes'
    - backup: ''
    - require:
      - pkg: zentyal

/etc/fetchmailrc:
  file.managed:
    - source: salt://roles/zentyal/mail/fetchmailrc
    - mode: 600
    - user: fetchmail
    - template: jinja
    - context:
        dataset: {{ salt['pillar.get']('zentyal:mail:fetchmail', ' ') }}
    - require:
      - pkg: zentyal

fetchmail:
  service.running:
    - enable: True
    - watch:
       - file: /etc/fetchmailrc
    - require:
       - file: /etc/default/fetchmail


# service generation


{% endif %}
