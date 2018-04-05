{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}

include:
  - lab.appliance.zentyal.base
  - lab.appliance.zentyal.zentyal

{% for f in ['create_zentyal_user.pl', 'list_zentyal_users.pl'] %}
/usr/local/sbin/{{ f }}:
  file.managed:
    - source: salt://lab/appliance/zentyal/files/{{ f }}
    - mode: "0755"
    - require:
      - sls: lab.appliance.zentyal.base
    #     - require_in:
    #      - cmd: create_zentyal_user

{% endfor %}

{% if settings.user|d(false) %}
# ### user creation
{% endif %}


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
    - require:
      - pkg: offlineimap
      - pkg: zentyal

/home/{{ settings.admin.user }}/.offlineimap/{{ settings.sync.functions.name }}:
  file.managed:
    - source: {{ settings.sync.functions.source }}
    - template: jinja
    - user: {{ settings.admin.user }}
    - makedirs: true
    - require:
      - pkg: offlineimap
      - pkg: zentyal
      - user: zentyal-admin-user

{% endif %}
