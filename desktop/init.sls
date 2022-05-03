{% if grains['os'] == 'Ubuntu' %}
include:
  - desktop.ubuntu
{% elif grains['os'] == 'Manjaro' %}
include:
  - desktop.manjaro
{% endif %}

desktop_packages:
  test:
    - nop
