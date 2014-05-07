{% from "roles/backupninja/defaults.jinja" import template with context %}
{% set backupninja=salt['grains.filter_by']({'none': template.backupninja }, 
  grain='none', default= 'none', merge= pillar.backupninja) %}

backupninja:
  pkg.installed:
    - pkgs:
      - backupninja
      - hwinfo

{% if backupninja.at == 'manual' %}

/etc/cron.d/backupninja:
  file.absent:
    - require:
      - pkg: backupninja

{% else %}

/etc/backupninja.conf:
  file.replace:
    - backup: False
    - pattern: "^when[ ]*=.*"
    - repl: "when = {{ backupninja.at }}"
    - require:
      - pkg: backupninja

/etc/cron.d/backupninja:
  file.managed:
    - source: salt://roles/backupninja/template/backupninja
    - require:
      - pkg: backupninja

{% endif %}

{% for typ, conf in backupninja.config.iteritems() %}
  {% for prio, cust in conf.iteritems() %}
    {% if cust is none %}{% set cust= {} %}{% endif %}

/etc/backup.d/{{ prio }}.{{ typ }}:
  file.managed:
    - source: salt://roles/backupninja/template/{{ typ }}
    - context: {{ cust }}
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - makedirs: True
    - require:
      - pkg: backupninja

  {% endfor %}
{% endfor %}
