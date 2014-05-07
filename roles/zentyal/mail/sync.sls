
offlineimap:
  pkg:
    - installed

{% if pillar.zentyal.mail.sync.config|d(false) %}

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

/home/{{ pillar.zentyal.admin.user }}/.offlineimap/helpers.py:
  file.managed:
    - source: {{ pillar.zentyal.mail.sync.helpers }}
    - template: jinja
    - user: {{ pillar.zentyal.admin.user }}
    - require:
      - pkg: offlineimap

{% endif %}
