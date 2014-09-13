include:
  - .ppa

bitcoin:
  pkg.installed:
    - require:
      - pkgrepo: bitcoin-ppa

#  secret sharing splitter/combiner
ssss:
  pkg:
    - installed

