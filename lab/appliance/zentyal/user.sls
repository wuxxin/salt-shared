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

{% if pillar.appliance.zentyal.user|d(false) %}
# ### user creation
{% endif %}


{% if pillar.appliance.zentyal.sync|d(false) %}
{# ### imap mail migration #}
offlineimap:
  pkg:
    - installed

/home/{{ pillar.appliance.zentyal.admin.user }}/.offlineimaprc:
  file.managed:
    - source: {{ pillar.appliance.zentyal.sync.config }}
    - template: jinja
    - user: {{ pillar.appliance.zentyal.admin.user }}
    - context:
        sync_sets: {{ pillar.appliance.zentyal.sync.set }}
        functions: {{ pillar.appliance.zentyal.sync.functions}}
    - require:
      - pkg: offlineimap
      - pkg: zentyal

/home/{{ pillar.appliance.zentyal.admin.user }}/.offlineimap/{{ pillar.appliance.zentyal.sync.functions.name }}:
  file.managed:
    - source: {{ pillar.appliance.zentyal.sync.functions.source }}
    - template: jinja
    - user: {{ pillar.appliance.zentyal.admin.user }}
    - makedirs: true
    - require:
      - pkg: offlineimap
      - pkg: zentyal
      - user: zentyal-admin-user

{% endif %}
