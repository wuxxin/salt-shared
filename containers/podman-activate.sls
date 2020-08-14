include:
  - containers

{% from "containers/lib.sls" import podman_volume, podman_container, podman_compose %}

{% for name,value in salt['pillar.get']('podman:volume', {}).items() %}
{{ podman_volume(name) }}
{% endfor %}

{% for name,pod in salt['pillar.get']('podman:container', {}).items() %}
{% set dummy = pod.__setitem__('name', name) %}
{{ podman_container(pod) }}
{% endfor %}

{% for name,compose in salt['pillar.get']('podman:compose', {}).items() %}
{% set dummy = compose.__setitem__('name', name) %}
{{ podman_compose(compose) }}
{% endfor %}
