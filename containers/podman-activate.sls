include:
  - containers

{% from "containers/lib.sls" import podman_volume, podman_container, podman_compose %}

{% for name,value in salt['pillar.get']('podman:volume', {}) %}
{{ podman_volume(name) }}
{% endfor %}

{% for name,pod in salt['pillar.get']('podman:container', {}) %}
{% set pod['container_name'] = name %}
{{ podman_container(pod) }}
{% endfor %}

{% for name,compose in salt['pillar.get']('podman:compose', {}) %}
{{ podman_compose(compose) }}
{% endfor %}
