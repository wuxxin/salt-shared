{% macro write_zone(zone, common, targetpath='', watch_in='') %}
  {%- set storagepath=
    dns.template|selectattr('id', 'equalto',
      zone.template|d('default'))|map(attribute='storage')|first %}
  {%- if targetpath %}
    {%- set targetfile = targetpath+ '/'+ zone.domain+ '.zone' %}
  {%- else %}
    {%- set targetfile = storagepath+ '/'+ zone.template|d('default')+ '/'+ zone.domain+ '.zone' %}
  {% endif %}
zone-{{ basepath}}-{{ zone.domain }}:
  file.managed:
    - name: {{ targetfile }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
  {%- if watch_in is defined %}
    - watch_in: knot.service
  {% endif %}
  {%- if zone.source is defined %}
    - template: jinja
    - source: {{ zone.source }}
    - defaults:
        domain: zone.domain
        common: {{ common }}
        autoserial: {{ salt['cmd.run_stdout']('date +%y%m%d%H%M') }}
    {%- if zone.context is defined %}
    - context: {{ zone.context }}
    {%- endif %}
  {%- else %}
    - contents: |
{{ zone.contents|d('')|indent(8, True) }}
  {%- endif %}
  {%- if zone.master is not defined %}
    - check_cmd: /usr/bin/kzonecheck -o {{ zone.domain }}
  {%- endif %}
{% endmacro %}
