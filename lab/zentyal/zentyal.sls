include:
  - .base
    
# ### hooks
{% for n in ['mail', 'openchange'] %}
/etc/zentyal/hooks/{{ n }}.postsetconf:
  file.managed:
    - source: salt://lab/zentyal/files/{{ n }}.postsetconf
    - template: jinja
    - mode: "755"
    - require:
      - sls: .base
{% endfor %}

# ### postfix
{% for filename, pillaritem in
    ('tls_policy_map', 'appliance:zentyal:mail:tls_policy'),
    ('generic_outgoing', 'appliance:zentyal:mail:rewrite'),
    ('recipient_bcc', 'appliance:zentyal:mail:incoming_bcc'),
    ('sender_bcc', 'appliance:zentyal:mail:outgoing_bcc'),
    ('transport_map', 'appliance:zentyal:mail:transport') %}

  {% if salt['pillar.get'](pillaritem, None) %}
/etc/postfix/{{ filename }}:
  file.managed:
    - source: salt://lab/zentyal/files/key_seperator_value.jinja
    - template: jinja
    - context:
        dataset: {{ salt['pillar.get'](pillaritem, None) }}
    - require:
      - sls: .zentyal
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
      - sls: .zentyal

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

{% if pillar.appliance.zentyal.mail.sync.config|d(false) %}
# ### imap mail migration
offlineimap:
  pkg:
    - installed

/home/{{ pillar.appliance.zentyal.admin.user }}/.offlineimaprc:
  file.managed:
    - source: {{ pillar.appliance.zentyal.mail.sync.config }}
    - template: jinja
    - user: {{ pillar.appliance.zentyal.admin.user }}
    - context:
        sync_sets: {{ pillar.appliance.zentyal.mail.sync.set }}
        admin_user: {{ pillar.appliance.zentyal.admin.user }}
    - require:
      - pkg: offlineimap
      - pkg: zentyal-mail

/home/{{ pillar.appliance.zentyal.admin.user }}/.offlineimap/helpers.py:
  file.managed:
    - source: {{ pillar.appliance.zentyal.mail.sync.helpers }}
    - template: jinja
    - user: {{ pillar.appliance.zentyal.admin.user }}
    - makedirs: true
    - require:
      - pkg: offlineimap
      - pkg: zentyal-mail
      - user: zentyal-admin-user
{% endif %}
