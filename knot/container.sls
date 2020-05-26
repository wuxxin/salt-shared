{% from "knot/defaults.jinja" import defaults, log_default, template_default %}
{% from "knot/zone.sls" import write_zone, write_config %}

{% set container_defaults = defaults %}
{% do container_defaults.server.update({'rundir': '/rundir'}) %}
{% do container_defaults.database.update({'storage': '/storage'}) %}
{% set container_template= template_default %}
{% do container_template.update({'storage': '/storage'}) %}

{% set settings=salt['grains.filter_by']({'none': defaults},
  grain='none', default= 'none', merge= salt['pillar.get']('container:knot', {})) %}

include:
  - podman

{% if settings.enabled|d(true) %}

{% load_yaml as knot_service %}
image:
  name: knot
container:
  name: {{ settings.name|d('container_knot') }}
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
        template_default: {{ container_template }}

{% from "podman/container.sls" import podman_container %}
{{ podman_container(knot_service) }}

{% endif %}
