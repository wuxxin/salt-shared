include:
  - vcs

{% if (grains['os'] == 'Ubuntu' and grains['osrelease'] == '14.04') %}
{% set golang='golang-1.6' %}
{% else %}
{% set golang='golang' %}
{% endif %}

golang:
  pkg.installed:
    - name: {{ golang }}
    - require:
      - sls: vcs
