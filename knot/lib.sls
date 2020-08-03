{% macro write_zone(zone, common, targetpath, watch_in='') %}
  {%- set targetfile = targetpath+ '/'+ zone.domain+ '.zone' %}

zone-{{ targetpath }}-{{ zone.domain }}:
  file.managed:
    - name: {{ targetfile }}
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
  {%- if watch_in %}
    - require_in: {{ watch_in }}
    - watch_in: {{ watch_in }}
  {% endif %}
  {%- if zone.source is defined %}
    - template: jinja
    - source: {{ zone.source }}
    - defaults:
        domain: zone.domain
        common: {{ common }}
    {%- if zone.context is defined %}
    - context: {{ zone.context }}
    {%- endif %}
  {%- else %}
    - contents: |
{{ zone.contents|d('')|indent(8, True) }}
  {%- endif %}
  {%- if zone.master is not defined %}
    - check_cmd: /usr/bin/kzonecheck -v -o {{ zone.domain }}
  {%- endif %}
{% endmacro %}


{% macro write_config(profilename, settings, log_default, template_default) %}
/etc/knot/knot{{ '' if not profilename else '-'+ profilename }}.conf:
  file.managed:
    - source: salt://knot/knot-template.conf.jinja
    - template: jinja
    - makedirs: true
    - user: knot
    - group: knot
    - mode: "0640"
    - defaults:
        settings: {{ settings }}
        log_default: {{ log_default }}
        template_default: {{ template_default }}
    - check_cmd: /usr/local/sbin/knot-config-check
    - require:
      - file: knot-config-check

/etc/default/knot{{ '' if not profilename else '-'+ profilename }}:
  file.managed:
    - contents: |
        KNOTD_ARGS="-c /etc/knot/knot{{ '' if not profilename else '-'+ profilename }}.conf"
        #

  {% if profilename %}
/etc/systemd/system/knot-{{ profilename }}.service:
  file.managed:
    - source: salt://knot/knot-template.service
    - template: jinja
    - defaults:
      profilename: {{ profilename }}
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/knot-{{ profilename }}.service
  {% endif %}
{% endmacro %}
