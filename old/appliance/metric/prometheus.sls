include:
  - appliance.base
  - systemd.reload
  - docker

{# XXX keep this list and the list in appliance-prepare-start-metric.sh in sync #}
{% load_yaml as settings %}
exporter_list: cadvisor node-exporter process-exporter postgres_exporter
server_list: prometheus alertmanager
gui_list: grafana
{% endload %}

{% macro metric_install(name) %}
/etc/systemd/system/{{ name }}.service:
  file.managed:
    - source: salt://appliance/metric/service/{{ name }}.service
    - template: jinja
    - onchanges_in:
      - cmd: systemd_reload

metric_service_{{ name }}:
  service.enabled:
    - name: {{ name }}
    - require:
      - sls: docker
      - file: /etc/systemd/system/{{ name }}.service
  # restarts service if changed and already running
  cmd.wait:
    - name: systemctl try-restart {{ name }}.service
    - watch:
      - file: /etc/systemd/system/{{ name }}.service

{% endmacro %}


{% if salt['pillar.get']('name', '') %}
{{ metric_install(pillar.name) }}

{% else %}

/app/etc/prometheus.yml:
  file.managed:
    - source: salt://appliance/metric/prometheus.yml
    - template: jinja
    - watch_in:
      - cmd: metric_service_prometheus

/app/etc/alertmanager.yml:
  file.managed:
    - source: salt://appliance/metric/alertmanager.yml
    - template: jinja
    - watch_in:
      - cmd: metric_service_alertmanager
      - cmd: metric_service_prometheus

/app/etc/alert.rules:
  file.managed:
    - source: salt://appliance/metric/alert.rules
    - watch_in:
      - cmd: metric_service_alertmanager
      - cmd: metric_service_prometheus

/app/etc/metric_import:
  file.directory:
    - makedirs: true
    - user: 1000
    - group: 1000

  {% for i in ['exporter_list', 'server_list', 'gui_list'] %}
/app/etc/tags/{{ i }}:
  file.managed:
    - contents: |
{{ settings[i]|indent(8,True) }}

    {% for n in settings[i].split(" ") %}
{{ metric_install(n) }}
    {% endfor %}
  {% endfor %}

{% endif %}
