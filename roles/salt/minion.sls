include:
  - .ppa

{% from "roles/salt/defaults.jinja" import settings as s with context %}
{% if s.install.type is defined and s.install.type == 'git' and salt.cmd.run('which salt-call') %}
{% set leave_alone= true %}
{% else %}
{% set leave_alone= false %}
{% endif %}

salt-minion:
{% if not leave_alone %}
  pkg.installed:
    - require:
      - pkgrepo: salt_ppa
{% endif %}
  service:
    - running
    - enable: true
    - require:
{% if not leave_alone %}
      - pkg: salt-minion
{% endif %}
      - pkg: psmisc
{% if grains['os'] == 'Debian' or grains['os'] == 'Ubuntu' %}
      - pkg: debconf-utils

debconf-utils:
  pkg:
    - installed
    - order: 1
{% endif %}

psmisc:
  pkg:
    - installed
    - order: 2

{% for source in ['update-salt-from-git.sh',] %}

create_usr_local_{{ source }}:
  file.managed:
    - name: /usr/local/sbin/{{ source }}
    - source: salt://roles/salt/files/{{ source }}
    - mode: 700

{% endfor %}
