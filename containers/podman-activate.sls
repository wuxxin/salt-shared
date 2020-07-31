include:
  - containers

{% from "containers/lib.sls" import podman_volume, podman_container, podman_compose %}

{% for name,value in salt['pillar.get']('podman:volume', {}) %}
{{ podman_volume(name) }}
{% endfor %}

{% for name,pod in salt['pillar.get']('podman:container', {}) %}
{% set dummy = pod.__setitem__('container_name', name) %}
{{ podman_container(pod) }}
{% endfor %}

{% for name,compose in salt['pillar.get']('podman:compose', {}) %}
{% set dummy = compose.__setitem__('service_name', name) %}
{{ podman_compose(compose) }}
{% endfor %}
