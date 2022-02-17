{% if grains['os'] == 'Ubuntu' %}
include:
  - desktop.ubuntu
{% endif %}

desktop_packages:
  test:
    - nop
