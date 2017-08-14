{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("sonic-pi-ppa", "sonic-pi/ppa") }}

{% endif %}

music_nop:
  test:
    - nop
