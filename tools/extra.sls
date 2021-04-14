include:
  - .qrcode
  - .stress
  - .audit

{% if grains['os_family'] == 'Debian' %}
extended-tools:
  pkg.installed:
    - pkgs:
      - blktrace    {# block layer IO tracing mechanism #}
      - unison      {# crossplatform file-synchronization tool #}
{% endif %}
