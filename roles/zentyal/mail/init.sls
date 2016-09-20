{% if salt['pillar.get']('zentyal:mail:status', "absent") == "present" %}
  {% if salt['pillar.get']('letsencrypt:enabled', false) %}
include:
  - letsencrypt
  {% endif %}


zentyal-mail:
  pkg.installed:
    - pkgs:
      - zentyal-mail
      - zentyal-mailfilter
      - zentyal-openchange
    - require:
      - pkg: zentyal

sogo-tmpreaper:
    file.replace:
      - name: /etc/tmpreaper.conf
      - pattern: |
          ^.*SHOWWARNING=.*
      - repl: SHOWWARNING=false
      - append_if_not_found: true
      - backup: false
      - require:
        - pkg: zentyal-mail

# ### letsencrypt preperation
  {% if salt['pillar.get']('letsencrypt:enabled', false) %}
    {% set domain = salt['pillar.get']('letsencrypt:domains', ['domain.not.set'])[0].split(' ')[0] %}

zentyal-apache-reload:
  service.running:
    - name: apache2
    - enable: True
    - watch:
      - file: /etc/apache2/conf-enabled/10-wellknown-acme.conf
    - require:
      - sls: letsencrypt

zentyal-letsencrypt-hook:
  file.managed:
    - name: /usr/local/etc/letsencrypt.sh/zentyal-letsencrypt-hook.sh
    - source: salt://roles/zentyal/mail/zentyal-letsencrypt-hook.sh
    - mode: "0755"
    - require:
      - sls: letsencrypt

initial-cert-creation:
  cmd.run:
    - name: /usr/local/bin/letsencrypt.sh -c
    - unless: test -e /usr/local/etc/letsencrypt.sh/certs/{{ domain }}/fullchain.pem
    - require:
      - service: zentyal-apache-reload
      - file: zentyal-letsencrypt-hook

  {% endif %}


# ### hooks
  {% for n in ['mail', 'openchange'] %}
/etc/zentyal/hooks/{{ n }}.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/mail/{{ n }}.postsetconf
    - template: jinja
    - mode: "755"
    - require:
      - pkg: zentyal-mail
  {% endfor %}

# ### postfix
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
    - makedirs: true
    - require:
      - pkg: offlineimap
      - pkg: zentyal-mail
      - user: zentyal-admin-user

  {% endif %}

{% endif %}
