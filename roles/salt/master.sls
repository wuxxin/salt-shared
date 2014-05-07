include:
  - .ppa
  - .minion
{% if pillar.salt.reactor.status=="present" %}
  - .reactor
{% endif %}

python-pip:
  pkg.installed

salt-master-dependencies:
  pip.installed:
    - name: GitPython
    - require:
      - pkg: python-pip

salt-master:
  pkg:
    - latest
    - require:
      - pkgrepo: salt_ppa
      - pip: salt-master-dependencies
  service:
    - running
    - require:
      - pkg: salt-master

/etc/salt/master:
  file.managed:
    - user: root
    - group: root
    - source: {{ pillar.salt.master.config }}
    - mode: 644
    - watch_in:
      - service: salt-master

{% if grains.salt_master|d(None)!= True %}

set_salt_master_grain:
  module.run:
    - name: grains.setval
      key: salt_master
      val: True
    - require:
      - pkg: salt-master 

{% endif %}

salt_create_bash_aliases:
  file:
    - touch
    - name: /root/.bash_aliases
    - require:
      - pkg: salt-master

salt_append_bash_aliases:
  file.append:
    - name: /root/.bash_aliases

    - text: |
        alias sa="salt"
        alias sar="salt-run"
        alias sac="salt-call"
        alias sast="salt-run manage.status"
    - require:
      - file: salt_create_bash_aliases
