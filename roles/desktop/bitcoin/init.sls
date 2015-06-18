include:
  - .ppa

bitcoin:
  pkg.installed:
    - pkgs:
      - bitcoin-qt
      - bitcoind
    - require:
      - cmd: bitcoin-ppa

#  secret sharing splitter/combiner
ssss:
  pkg:
    - installed

