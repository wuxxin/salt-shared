{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("bitcoin_ppa", "bitcoin/bitcoin",
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
