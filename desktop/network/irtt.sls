{%- if grains['osmajorrelease']|int >= 18 %}

irtt:
  pkg.installed:
    - name: irtt

{%- else %}

include:
  - golang

{% from 'golang/lib.sls' import go_build_from_git with context %}

{% load_yaml as config %}
source:
  repo: 'https://github.com/peteheist/irtt.git'
  rev: 'v0.9.0'
build:
  check: 'irtt'
  bin_files: ['irtt']
{% endload %}

{{ go_build_from_git(config) }}

{% endif %}
