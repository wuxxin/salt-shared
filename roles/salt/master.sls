{% from "roles/salt/defaults.jinja" import settings as s with context %}
{% if s.install.type is defined and s.install.type == 'git' and salt.cmd.run('which salt') %}
{% set leave_alone= true %}
{% else %}
{% set leave_alone= false %}
{% endif %}

include:
  - python
  - .ppa
  - .minion
{% if s.master.reactor.status=="present" %}
  - .reactor
{% endif %}
{% if s.master.gitcrypt.status=="present" %}
  - git-crypt
  - gnupg
{% endif %}
{% if s.master.extensions.status=="present" %}
  - .extensions
{% endif %}


salt-master-dependencies:
  pip.installed:
    - name: GitPython
    - require:
      - pkg: python

salt-master:
{% if leave_alone %}
  cmd.run:
    - name: which salt
{% else %}
  pkg.installed:
{% endif %}
    - require:
      - pkgrepo: salt_ppa
      - pip: salt-master-dependencies
{% if s.master.gitcrypt.status=="present" %}
      - cmd: git-crypt
      - pkg: gnupg
{% endif %}
  service.running:
    - enable: true
    - require:
{% if leave_alone %}
      - cmd: salt-master
{% else %}
      - pkg: salt-master
{% endif %}


/etc/salt:
  file:
    - directory

/etc/salt/master.d:
  file:
    - directory
    - require:
      - file: /etc/salt

/etc/salt/master:
  file.managed:
    - contents: |
{{ s.master.config|indent(8, true) }}

    - mode: 644
    - require:
      - file: /etc/salt
    - watch_in:
      - service: salt-master

{% for f, d in s.master_d.iteritems() %}
/etc/salt/master.d/{{ f }}.conf:
  file.managed:
    - contents: |
{{ d|yaml(False)|indent(8,True) }}

    - watch_in:
      - service: salt-master

{% endfor %}


{% if grains.salt_master|d(None)!= True %}

set_salt_master_grain:
  module.run:
    - name: grains.setval
      key: salt_master
      val: True
    - require:
      - service: salt-master

{% endif %}

salt-master-in-hosts:
  host.present:
    - name: salt
    - ip: 127.0.0.1

salt_create_bash_aliases:
  file:
    - touch
    - name: /root/.bash_aliases

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
