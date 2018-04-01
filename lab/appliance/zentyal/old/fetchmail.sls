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

/etc/fetchmailrc:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/fetchmailrc
    - mode: 600
    - user: fetchmail
    - template: jinja
    - context:
        dataset: {{ salt['pillar.get']('appliance:zentyal:fetchmail', '') }}
  