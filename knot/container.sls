{% from "knot/defaults.jinja" import container_settings as settings with context %}
{% from "knot/defaults.jinja" import log_default, template_default %}
{% from "knot/zone.sls" import write_zone %}

include:
  - podman

{% if settings.enabled|d(true) %}

{% load_yaml as knot_service %}
image:
  name: knot
container:
  name: {{ settings.name|d('container_knot') }}
  start: true
  remove_on_stop: false
  update_on_start: true
  env:
{% endload %}

{%- for zone in settings.zone %}
{{ write_zone(zone, settings.common, targetpath=user_home+ '/knot.container') }}
{%- endfor %}

{{ user_home }}/knot.container/knot.conf:
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

{% from "podman/container.sls" import podman_container %}
{{ podman_container(knot_service) }}

{% endif %}
