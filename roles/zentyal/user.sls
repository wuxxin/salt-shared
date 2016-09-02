# ### user creation

/usr/local/sbin/create_zentyal_user.pl:
  file.managed:
    - source: salt://roles/zentyal/tools/create_zentyal_user.pl
    - mode: 755
    - require:
      - pkg: zentyal

{% if pillar.zentyal.user|d(false) %}
  {% for n,v in pillar.zentyal.user.iteritems() %}

create_zentyal_user_{{ n }}:
  cmd.run:
    - name: echo "{{ v|join(',') }}" | /usr/local/sbin/create_zentyal_user.pl
    - unless: /usr/share/zentyal/shell 'instance users; exit 1 if not $users->userExists("{{ n }}");'
    - require:
      - pkg: zentyal
      - file: /usr/local/sbin/create_zentyal_user.pl

  {% endfor %}
{% endif %}
