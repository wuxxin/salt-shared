include:
  - containers

{% from "containers/lib.sls" import env_repl, vol_path, usernsid_fromstr, volume, image, container, compose %}

{% for vol in salt['pillar.get']('podman:volume', []) %}
{{ volume(vol.name) }}
{% endfor %}

{% for pod in salt['pillar.get']('podman:container', []) %}
{{ container(pod) }}
{% endfor %}

{% for comp in salt['pillar.get']('podman:compose', []) %}
{{ compose(comp) }}
{% endfor %}
