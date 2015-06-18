{% from "roles/salt/defaults.jinja" import settings as s with context %}
{% if s.install.type is defined and s.install.type == 'git' and salt.cmd.run('which salt-call') %}
{% set leave_alone= true %}{# we do not intervene if salt is installed from git #}
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
  - at

salt-minion:
  pkg.installed:
    - require:
      - cmd: salt_ppa
  service.running:
    - enable: true
    - require:
      - pkg: salt-minion
      - pkg: psmisc
{%- if grains['os'] == 'Debian' or (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
      - pkg: debconf-utils
{%- endif %}
  cmd.wait:
    - name: echo service salt-minion restart | at now + 1 minute
    - watch:
      - pkg: salt-minion

{% if grains['os'] == 'Debian' or (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
debconf-utils:
  pkg:
    - installed
    - order: 1
{% endif %}

psmisc:
  pkg:
    - installed
    - order: 2

{% endif %}


{% for source in ['update-salt-from-git.sh',] %}

create_usr_local_{{ source }}:
  file.managed:
    - name: /usr/local/sbin/{{ source }}
    - source: salt://roles/salt/files/{{ source }}
    - mode: 700

{% endfor %}
