{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("bitcoin-ppa", "bitcoin/bitcoin",
  require_in= "pkg: bitcoin") }}
{% endif %} 

bitcoin:
  pkg.installed:
    - pkgs:
      - bitcoin-qt
      - bitcoind

#  secret sharing splitter/combiner
ssss:
  pkg:
    - installed

