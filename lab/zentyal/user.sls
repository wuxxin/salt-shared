include:
  - .base

# ### user creation
/usr/local/sbin/create_zentyal_user.pl:
  file.managed:
    - source: salt://lab/zentyal/files/create_zentyal_user.pl
    - mode: "0755"
    - require:
      - sls: base

{% if pillar.appliance.zentyal.user|d(false) %}
  {% for n,v in pillar.appliance.zentyal.user.iteritems() %}

create_zentyal_user_{{ n }}:
  cmd.run:
    - name: echo "{{ v|join(',') }}" | /usr/local/sbin/create_zentyal_user.pl
    - unless: /usr/share/zentyal/shell 'instance users; exit 1 if not $users->userExists("{{ n }}");'
    - require:
      - sls: zentyal
      - file: /usr/local/sbin/create_zentyal_user.pl

  {% endfor %}
{% endif %}
