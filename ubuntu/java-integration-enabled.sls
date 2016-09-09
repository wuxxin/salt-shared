{% if grains['lsb_distrib_codename'] == 'trusty' %}

include:
  - .ppa
  - java

jayatana:
  pkg:
    - installed
    - require:
      - cmd: jayatana-ppa
      - pkg: default-jre

{% endif %}
