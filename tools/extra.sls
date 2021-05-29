include:
  - tools
  - tools.qrcode
  - tools.stress
  - tools.audit

{% if grains['os_family'] == 'Debian' %}
extended-tools:
  pkg.installed:
    - pkgs:
      - blktrace    {# block layer IO tracing mechanism #}
{% endif %}
