include:
  - .qrcode
  - .stress
  - .forensic

{% if grains['os_family'] == 'Debian' %}
extended-tools:
  pkg.installed:
    - pkgs:
      - blktrace    {# block layer IO tracing mechanism #}
{% endif %}
