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
    - watch_in: {{ watch_in }}
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


{% macro write_config(profilename, settings, log_default, template_default) %}
/etc/knot/knot{{ '' if not profilename else '-'+ profilename }}.conf:
  file.managed:
    - source: salt://knot/knot.jinja
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
    - contents: |
        [Unit]
        Description=Knot DNS server - {{ profilename }}
        Wants=network-online.target
        After=network-online.target
        Documentation=man:knotd(8) man:knot.conf(5) man:knotc(8)

        [Service]
        Type=notify
        User=knot
        Group=knot
        CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_SETPCAP
        AmbientCapabilities=CAP_NET_BIND_SERVICE CAP_SETPCAP
        ExecStartPre=/usr/sbin/knotc -c /etc/knot/knot-{{ profilename }}.conf conf-check
        ExecStart=/usr/sbin/knotd -c /etc/knot/knot-{{ profilename }}.conf
        ExecReload=/usr/sbin/knotc -c /etc/knot/knot-{{ profilename }}.conf reload
        Restart=on-abort
        LimitNOFILE=1048576

        [Install]
        WantedBy=multi-user.target
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/knot-{{ profilename }}.service
  {% endif %}
{% endmacro %}
