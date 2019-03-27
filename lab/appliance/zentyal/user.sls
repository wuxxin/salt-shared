{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - lab.appliance.zentyal.zentyal
  
{% for f in ['create_zentyal_user.pl', 'list_zentyal_users.pl'] %}
/usr/local/sbin/{{ f }}:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/{{ f }}
    - mode: "0755"
    - require:
      - sls: lab.appliance.zentyal.zentyal
{% endfor %}


{% if settings.sync|d(false) %}
{# ### imap mail migration #}
{# Python v3.4+ [STALLED] (experimental: see known issues)
https://github.com/OfflineIMAP/offlineimap/issues?q=is%3Aissue+is%3Aopen+label%3APy3 #}
{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install('offlineimap') }}

/home/{{ settings.admin.user }}/.offlineimaprc:
  file.managed:
    - source: {{ settings.sync.config }}
    - template: jinja
    - user: {{ settings.admin.user }}
    - group: {{ settings.admin.user }}
    - context:
        sync_sets: {{ settings.sync.set }}
        functions: {{ settings.sync.functions}}
        users: {{ settings.user }}
    - require:
      - pip: offlineimap
      - sls: lab.appliance.zentyal.zentyal

/home/{{ settings.admin.user }}/.offlineimap/{{ settings.sync.functions.name }}:
  file.managed:
    - source: {{ settings.sync.functions.source }}
    - template: jinja
    - user: {{ settings.admin.user }}
    - group: {{ settings.admin.user }}
    - mode: "0755"
    - makedirs: true
    - require:
      - pip: offlineimap
      - sls: lab.appliance.zentyal.zentyal

{% endif %}
