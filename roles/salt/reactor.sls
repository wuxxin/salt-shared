include:
  - .master

{% set reactor_previous={} %}
{% for part in pillar.salt.reactor.includes|d({}) %}
  {% import_yaml part+"/reactor/reactor.conf" as single_reactor %}
  {% set reactor_next=salt['grains.filter_by']({'default': reactor_previous}, grain='none', merge= single_reactor|d({})) %}
  {% set reactor_previous=reactor_next %}
{% endfor %}

{% set reactor_dict= reactor_previous %}

/etc/salt/master.d/reactor.conf:
  file.managed:
    - source: salt://roles/salt/reactor.conf
    - template: jinja
    - context: 
        reactor: {{ reactor_dict }}
        basepath: {{ pillar.salt.reactor.basepath }}
    - watch_in:
      - service: salt-master

{{ pillar.salt.reactor.basepath }}:
  file:
    - directory

{% for event, func_list in reactor_dict.iteritems() %}
{% for func_dest, func_source in func_list.iteritems() %}

"{{pillar.salt.reactor.basepath }}/{{ func_dest }}":
  file.managed:
    - source: {{ func_source }}
    - watch_in:
      - file: /etc/salt/master.d/reactor.conf

{% endfor %}
{% endfor %}
