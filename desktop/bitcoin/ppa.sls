{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %} 

{% if grains['os'] == 'Ubuntu' %} 

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("bitcoin-ppa", "bitcoin/bitcoin") }}

{% endif %} 

bitcoin_nop:
  test:
    - nop
