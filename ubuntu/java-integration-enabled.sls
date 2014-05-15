include:
  - .ppa
  - java

jayatana:
  pkg:
    - installed
    - require:
      - pkgrepo: jayatana-ppa
      - pkg: default-jre

