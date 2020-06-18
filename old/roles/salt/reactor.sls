include:
  - .master

{% from "old/roles/salt/defaults.jinja" import settings as s with context %}
{% set reactor_dict={} %}
{% for part in s.master.reactor.includes|d({}) %}
  {% import_yaml part+"/reactor/reactor.conf" as single_reactor %}
  {% do reactor_dict.update(single_reactor) %}
{% endfor %}

/etc/salt/master.d/reactor.conf:
  file.managed:
    - source: salt://old/roles/salt/files/reactor.conf
    - template: jinja
    - context: 
        reactor: {{ reactor_dict }}
    - require:
      - file: /etc/salt/master.d
    - watch_in:
      - service: salt-master

