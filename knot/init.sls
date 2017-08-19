include:
  - ubuntu

{% if salt['pillar.get']('knot', false) %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("knot-ppa", "cz.nic-labs/knot-dns") }}

{% from "knot/defaults.jinja" import settings with context %}

knot:
  pkg.installed:
    - names:
      - knot
    - require:
      - pkgrepo: knot-ppa

/usr/sbin/knot-config-check:
  file.managed:
    - contents: |
        #!/bin/sh
        /usr/sbin/knotc -c $1 conf-check
        exit $?
    - mode: "0755"
    - require:
      - pkg: knot

  {%- for server in settings.instance|d([]) %}
    
    {%- set common_name = 'knot' if server.id == 'default' else 'knot-'+ server.id %}
    
    {%- if grains['osrelease_info'][0] < 16 %}
      {% load_yaml as service %}
name: {{ common_name }}
file: /etc/init.d/{{ common_name }}
mode: "0755"
source: salt://knot/knot.init.d
conf: /etc/knot/{{ common_name }}.conf
      {% endload %}
    {%- else %}
      {% load_yaml as service %}
name: {{ common_name }}.service
file: /etc/systemd/{{ common_name }}.service
mode: "0644"
source: salt://knot/knot.service
conf: /etc/knot/{{ common_name }}.conf
      {% endload %}
    {%- endif %}  
    
    {%- if server.active|d(false) %}

default-knot-{{ server.id }}:
  file.managed:
    - name: /etc/default/{{ common_name }}
    - contents: |
        KNOTD_ARGS="-c {{ service.conf }}"
        #
          
knot-config-{{ server.id }}:
  file.managed:
    - name: {{ service.conf }}
    - source: salt://knot/knot.jinja
    - template: jinja
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - context:
        server: {{ server }}
    - check_cmd: /usr/sbin/knot-config-check

knot-{{ server.id }}.service:
  service.running:
    - name: {{ service.name }}
    - enable: true
    - require:
      - pkg: knot
    - watch:
      - file: default-knot-{{ server.id }}
      - file: knot-config-{{ server.id }}
      {%- if server.id != 'default' %}
      - file: knot-{{ server.id }}.service
    - require:
      - file: knot-{{ server.id }}.service  
  file.managed:
    - name: {{ service.file }}
    - source: {{ service.source }}
    - mode: "{{ service.mode }}"
    - template: jinja
    - context:
        identity: {{ common_name }}
      {%- endif %}

      {%- for zone in server.zone %}
knot-{{ server.id }}-zone-{{ zone.domain }}:
        {%- set targetfile = '/var/lib/knot/' + server.id+ '/'+ zone.template|d('default')+ '/'+ zone.domain+ '.zone' %}
        {%- if zone.source is not defined %}
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
    - source: {{ zone.source }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - watch_in: knot-{{ server.id }}.service
    - context:
        common: {{ settings.common }}
        {%- endif %}
      {%- endfor %}

    {%- else %}
knot-config-{{ server.id }}:
  file.absent:
    - name: {{ service.conf }}

knot-{{ server.id }}.service:
  service.dead:
    - name: {{ service.name }}
      {%- if server.id != 'default' %}
  file.absent:
    - name: {{ service.file }}
      {%- endif %}
    
    {%- endif %}
    
  {%- endfor %}
{%- endif %}

