include:
  - tools
  - tools.qrcode
  - tools.passgen
  - tools.stress

{% if grains['os_family'] == 'Debian' %}
extended-tools:
  pkg.installed:
    - pkgs:
      - blktrace    {# block layer IO tracing mechanism #}
{% endif %}
