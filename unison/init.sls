include:
  - .ppa

unison:
  pkg:
    - installed
{% if grains['lsb_distrib_codename'] in ['wily', 'xenial'] %}
    - require:
      - cmd: john_freeman_unison_ppa
{% elif grains['lsb_distrib_codename'] in ['trusty', 'precise'] %}
    - require:
      - cmd: sao_backports_ppa
{% endif %}
