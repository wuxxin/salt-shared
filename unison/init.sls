include:
  - .ppa

unison:
  pkg:
    - installed
{% if grains['lsb_distrib_codename']  == 'xenial' %}
    - require:
      - cmd: john_freeman_unison_ppa
{% elif grains['lsb_distrib_codename'] == 'trusty' %}
    - require:
      - cmd: sao_backports_ppa
{% endif %}
