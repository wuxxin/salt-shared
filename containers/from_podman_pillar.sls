include:
  - containers

{% from "containers/lib.sls" import volume, container, compose with context %}

{% for vol in salt['pillar.get']('podman:volume', []) %}
{{ volume(vol.name) }}
{% endfor %}

{% for pod in salt['pillar.get']('podman:container', []) %}
{{ container(pod) }}
{% endfor %}

{% for comp in salt['pillar.get']('podman:compose', []) %}
{{ compose(comp) }}
{% endfor %}
