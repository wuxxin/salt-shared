{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}


{% if settings.sync|d(false) %}
{# ### imap mail migration #}
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

{% endif %}


{% if settings.user|d(false) %}
# ### user creation

  {% for name, data in settings.user.iteritems() %}
create_zentyal_user_{{ name }}:
  cmd.run:
    - name: echo "{{ name }},{{ data['firstname'] }},{{ data['lastname'] }},{{ data['password'] }}" | /usr/local/sbin/create_zentyal_user.pl

  {% endfor %}
#     - require_in:
#      - sls: lab.appliance.zentyal.zentyal
#      - sls: lab.appliance.zentyal.storage

{% endif %}