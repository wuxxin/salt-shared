{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - lab.appliance.zentyal.zentyal
  - lab.appliance.zentyal.storage

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
offlineimap:
  pkg:
    - installed

/home/{{ settings.admin.user }}/.offlineimaprc:
  file.managed:
    - source: {{ settings.sync.config }}
    - template: jinja
    - user: {{ settings.admin.user }}
    - context:
        sync_sets: {{ settings.sync.set }}
        functions: {{ settings.sync.functions}}
        users: {{ settings.user }}
    - require:
      - pkg: offlineimap
      - sls: lab.appliance.zentyal.zentyal

/home/{{ settings.admin.user }}/.offlineimap/{{ settings.sync.functions.name }}:
  file.managed:
    - source: {{ settings.sync.functions.source }}
    - template: jinja
    - user: {{ settings.admin.user }}
    - makedirs: true
    - require:
      - pkg: offlineimap
      - sls: lab.appliance.zentyal.zentyal

{% endif %}

{% if settings.user|d(false) %}
# ### user creation
#     - require_in:
#      - sls: lab.appliance.zentyal.zentyal
#      - sls: lab.appliance.zentyal.storage
{% endif %}
