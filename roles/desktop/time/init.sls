{% if grains['lsb_distrib_codename'] == 'trusty' %}
include:
  - .ppa
  - .user

hamster-time-tracker:
  pkg:
    - installed
    - require:
      - cmd: hamster_ppa
{% endif %}
