include:
  - ubuntu

{% if salt['pillar.get']('knot', false) %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("knot-ppa", "cz.nic-labs/knot-dns") }}

{% load_yaml as defaults %}
ttl: 7200         {# 2 hours #}
refresh: 14400    {# 4 hours #}
retry: 1800       {# 30 min #}
expire: 1814400   {# 3 weeks #}
nxdomain: 14400   {# 4 hours #}
{% endload %}

knot:
  pkg.installed:
    - names:
      - knot
    - require:
      - pkgrepo: knot-ppa

  {%- for server in salt['pillar.get']('knot') %}
    {%- if server.active|d(false) == false %}

knot-config-{{ server.id }}:
  file.absent:
    - name: /etc/knot/knot-{{ server.id }}.conf
knot-{{ server.id }}.service:
      {%- if grains['osrelease_info'][0] < 16 %}
  service.dead:
    - name: knot-{{ server.id }}
  file.absent:
    - name: /etc/init.d/knot-{{ server.id }}
      {%- else %}
  service.dead:
    - name: knot-{{ server.id }}.service
  file.absent:
    - name: /etc/systemd/knot-{{ server.id }}.service
      {%- endif %}

    {%- else %}

knot-config-{{ server.id }}:
  file.managed:
    - name: /etc/knot/knot-{{ server.id }}.conf
    - template: jinja
    - source: salt://knot/knot.yml
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - context:
        dns: {{ server }}

      {%- for zone in server.zone %}
knot-{{ server.id }}-zone-{{ zone.domain }}:
        {%- set targetfile = '/var/lib/knot/' + server.id+ '/'+ zone.template|d('unsigned')+ '/'+ zone.domain+ '.zone' %}
        {%- if zone.file is not defined %}
  file.present:
    - name: {{ targetfile }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
        {%- else %}
  file.managed:
    - name: {{ targetfile }}
    - template: jinja
    - source: {{ zone.file }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - watch_in: knot-{{ server.id }}.service
    - context:
        dns: {{ server }}
        common: {{ server.common|d(defaults) }}
        {%- endif %}
      {%- endfor %}

/etc/default/knot-{{ server.id }}:
  file.managed:
    - contents: |
        KNOTD_ARGS="-c /etc/knot/knot-{{ server.id }}.conf"
        #
        

knot-{{ server.id }}.service:
  file.managed:
      {%- if grains['osrelease_info'][0] < 16 %}
    - name: /etc/init.d/knot-{{ server.id }}
    - source: salt://knot/knot.init.d
    - mode: "0755"

      {%- else %}
    - name: /etc/systemd/knot-{{ server.id }}.service
    - source: salt://knot/knot.service
      {%- endif %}
      
    - template: jinja
    - context:
        identity: {{ server.id }}
{#      
  service.running:
      {%- if grains['osrelease_info'][0] < 16 %}
    - name: knot-{{ server.id }}
      {%- else %}
    - name: knot-{{ server.id }}.service
      {%- endif %}
    - enable: true
    - require:
      - pkg: knot
    - watch:
        - file: knot-config-{{ server.id }}
        - file: knot-{{ server.id }}.service
#}    
    {%- endif %}
  {%- endfor %}
{%- endif %}

