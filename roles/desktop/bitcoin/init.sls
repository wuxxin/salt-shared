include:
  - .ppa

bitcoin:
  pkg.installed:
    - pkgs:
      - bitcoin-qt
      - bitcoind
    - require:
      - pkgrepo: bitcoin-ppa

#  secret sharing splitter/combiner
ssss:
  pkg:
    - installed

