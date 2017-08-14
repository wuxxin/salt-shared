{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("bitcoin-ppa", "bitcoin/bitcoin") }}

{% endif %} 

bitcoin_nop:
  test:
    - nop
