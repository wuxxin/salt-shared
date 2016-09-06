{% if salt['pillar.get']('zentyal:mail:status', "absent") == "present" %}

zentyal-mail:
  pkg.installed:
    - pkgs:
      - zentyal-mail
      - zentyal-mailfilter
      - zentyal-openchange
    - require:
      - pkg: zentyal

# ### postfix
/etc/zentyal/hooks/mail.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/mail/mail.postsetconf
    - mode: 755
    - require:
      - pkg: zentyal-mail

  {% for filename, pillaritem in
    ('tls_policy', 'zentyal:mail:tls_policy'),
    ('generic_outgoing', 'zentyal:mail:rewrite'),
    ('recipient_bcc', 'zentyal:mail:incoming_bcc'),
    ('sender_bcc', 'zentyal:mail:outgoing_bcc'),
    ('custom_transport', 'zentyal:mail:transport') %}

    {% if salt['pillar.get'](pillaritem, None) %}

/etc/postfix/{{ filename }}:
  file.managed:
    - source: salt://roles/zentyal/mail/key_seperator_value.jinja
    - template: jinja
    - context:
        dataset: {{ salt['pillar.get'](pillaritem, None) }}
    - require:
      - pkg: zentyal-mail
  cmd.run:
    - name: postmap /etc/postfix/{{ filename }}
    - watch:
       - file: /etc/postfix/{{ filename }}

    {% endif %}
  {% endfor %}

# ### dovecot
/etc/dovecot/extra.conf:
  file.managed:
    - contents: |
        namespace {
          type = private
          separator = /
          prefix =
          #location defaults to mail_location.
          inbox = yes
        }

        namespace {
          type = public
          separator = /
          prefix = public/
          location = maildir:/var/vmail/public
          subscriptions = yes
          #list = children
        }
    - require:
      - pkg: zentyal-mail

# ### fetchmail
fetchmail:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
       - file: /etc/fetchmailrc
    - require:
       - file: /etc/default/fetchmail

/etc/default/fetchmail:
  file.replace:
    - pattern: |
        ^.*START_DAEMON=.*
    - repl: START_DAEMON=yes
    - append_if_not_found: true
    - backup: false
    - require:
      - pkg: fetchmail
      - pkg: zentyal-mail

/etc/fetchmailrc:
  file.managed:
    - source: salt://roles/zentyal/mail/fetchmailrc
    - mode: 600
    - user: fetchmail
    - template: jinja
    - context:
        dataset: {{ salt['pillar.get']('zentyal:mail:fetchmail', ' ') }}
    - require:
      - pkg: zentyal-mail


  {% if pillar.zentyal.mail.sync.config|d(false) %}
# ### imap mail migration
offlineimap:
 pkg:
   - installed

/home/{{ pillar.zentyal.admin.user }}/.offlineimaprc:
  file.managed:
    - source: {{ pillar.zentyal.mail.sync.config }}
    - template: jinja
    - user: {{ pillar.zentyal.admin.user }}
    - context:
        sync_sets: {{ pillar.zentyal.mail.sync.set }}
        admin_user: {{ pillar.zentyal.admin.user }}
    - require:
      - pkg: offlineimap
      - pkg: zentyal-mail

/home/{{ pillar.zentyal.admin.user }}/.offlineimap/helpers.py:
 file.managed:
   - source: {{ pillar.zentyal.mail.sync.helpers }}
   - template: jinja
   - user: {{ pillar.zentyal.admin.user }}
   - require:
     - pkg: offlineimap
     - pkg: zentyal-mail

  {% endif %}

{% endif %}
