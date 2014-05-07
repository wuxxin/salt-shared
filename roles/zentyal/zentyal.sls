test_for_precise:
  cmd.run:
    - name: test "precise" = {{ grains['lsb_distrib_codename'] }}

# ### package installation

zentyal:
  pkg.installed:
    - pkgs:
      - zentyal
    - require:
      - pkgrepo: zentyal_main_ubuntu
      - pkgrepo: zentyal_extra_ubuntu
      - cmd: test_for_precise

set_os_extra:
  module.run:
    - name: grains.setval
      key: os_extra
      val: zentyal
    - require:
      - pkg: zentyal

set_zentyal_version:
  module.run:
    - name: grains.setval
      key: zentyal_version
      val: {{ salt['cmd.run_stdout']('dpkg -s zentyal | grep "^Version" | sed -re "s/Version:.(.+)/\\1/g"') }}
    - require:
      - pkg: zentyal

# ### user creation

/usr/local/sbin/create_zentyal_user.pl:
  file.managed:
    - source: salt://roles/zentyal/create_zentyal_user.pl
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


