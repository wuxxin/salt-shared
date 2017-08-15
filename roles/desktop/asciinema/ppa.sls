{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("asciinema-ppa", "zanchey/asciinema") }}

{% endif %}

asciinema_nop:
  test:
    - nop