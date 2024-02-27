include:
  - python              {# basic python environment #}
  - tools.jinja2cli     {# Jinja templating language cli interface #}
  - tools.flatyaml      {# convert yaml to a flat key=value format #}
  - tools.sentry        {# sentrycat.py error reporting to sentry #}

{% import_yaml 'tools/tools.yml' as tools %}

{% if grains['os_family'] == 'Arch' %}
base-tools:
  pkg.installed:
    - pkgs: {{ tools.pkgs.arch }}

{% elif grains['os_family'] == 'Debian' %}
base-tools:
  pkg.installed:
    - pkgs: {{ tools.pkgs.debian }}

{% endif %}
