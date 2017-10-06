include:
  - systemd.reload
  - docker

{% macro metric_install(name) %}
/etc/systemd/system/{{ name }}.service:
  file.managed:
    - source: salt://appliance/metric/{{ name }}.service
    - template: jinja
    - watch_in:
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

{{ metric_install('cadvisor') }}
{{ metric_install('node-exporter') }}
{{ metric_install('postgres_exporter') }}
{{ metric_install('process-exporter') }}
{{ metric_install('alertmanager') }}
{{ metric_install('prometheus') }}
{{ metric_install('grafana') }}

{% endif %}
