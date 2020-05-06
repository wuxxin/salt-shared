{% from "roles/salt/defaults.jinja" import settings as s with context %}
{% if s.install.type is defined and s.install.type == 'git' and salt.cmd.run('which salt-call') %}
  {# we do not intervene if salt is installed from git #}
  {% set leave_alone= true %}
  {% for source in ['update-salt-from-git.sh',] %}
create_usr_local_{{ source }}:
  file.managed:
    - name: /usr/local/sbin/{{ source }}
    - source: salt://roles/salt/files/{{ source }}
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

psmisc:
  pkg:
    - installed

  {% if grains['os_family'] == 'Debian' %}
debconf-utils:
  pkg:
    - installed

Disable starting services:
  file.managed:
    - name: /usr/sbin/policy-rc.d
    - user: root
    - group: root
    - mode: 0755
    - contents:
      - '#!/bin/sh'
      - exit 101
    # do not touch if already exists
    - replace: False
    - prereq:
      - pkg: Upgrade Salt Minion

  {% endif %}

Upgrade Salt Minion:
  pkg.installed:
    - name: salt-minion
    - version: latest
    - order: last

Enable Salt Minion:
  service.enabled:
    - name: salt-minion
    - require:
      - pkg: Upgrade Salt Minion

  {%- if grains['os_family'] == 'Debian' %}
Enable starting services:
  file.absent:
    - name: /usr/sbin/policy-rc.d
    - onchanges:
      - pkg: Upgrade Salt Minion
  {%- endif %}

  {%- if grains['os'] != 'Windows' %}
  Restart Salt Minion:
    cmd.run:  
      - name: 'salt-call --local service.restart salt-minion'
      - bg: True
      - onchanges:
        - pkg: Upgrade Salt Minion
  {%- endif %}
  
{% endif %}