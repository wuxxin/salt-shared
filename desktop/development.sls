{% if grains['os'] == 'Ubuntu' %}
include:
  - desktop.ubuntu.development
{% elif grains['os'] == 'Manjaro' %}
include:
  - desktop.manjaro.development
{% endif %}

desktop_development_packages:
  test:
    - nop
