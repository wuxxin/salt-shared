{% from "roles/salt/defaults.jinja" import settings as s with context %}

include:
  - .ppa
  - .minion
{% if s.reactor.status=="present" %}
  - .reactor
{% endif %}
{% if s.gitcrypt.status=="present" %}
  - git-crypt
  - gnupg
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
{% if s.gitcrypt.status=="present" %}
      - cmd: git-crypt
      - pkg: gnupg
{% endif %}
  service:
    - running
    - require:
      - pkg: salt-master

/etc/salt/master:
  file.managed:
    - contents: |
{{ s.master.config|indent(8, true) }}

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
