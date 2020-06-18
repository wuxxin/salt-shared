{% from "old/roles/salt/defaults.jinja" import settings as s with context %}
{% if s.install.type is defined and s.install.type == 'git' and salt.cmd.run('which salt-call') %}
  {# we do not intervene if salt is installed from git #}
  {% set leave_alone= true %}
  {% for source in ['update-salt-from-git.sh',] %}
create_usr_local_{{ source }}:
  file.managed:
    - name: /usr/local/sbin/{{ source }}
    - source: salt://old/roles/salt/files/{{ source }}
    - mode: 700
  {% endfor %}
{% else %}
  {% set leave_alone= false %}
{% endif %}

{% if leave_alone %}
salt-minion:
  service.running:
    - enable: true

{% else %}
include:
  - .ppa

  {% if grains['os_family'] == 'Debian' %}
debconf-utils:
  pkg:
    - installed
    - order: 1
  {% endif %}

psmisc:
  pkg:
    - installed
    - order: 2
at:
  pkg:
    - installed
  service.running:
    - name: atd
    - enable: true
    - require:
      - pkg: at

salt-minion:
  pkg.installed:
    - require:
      - pkgrepo: salt_ppa
  service.running:
    - enable: true
    - require:
      - pkg: salt-minion
      - pkg: psmisc
  {%- if grains['os_family'] == 'Debian' %}
      - pkg: debconf-utils
  {%- endif %}
  cmd.wait:
    - name: echo service salt-minion restart | at now + 1 minute
    - order: latest
    - watch:
      - pkg: salt-minion
{% endif %}


