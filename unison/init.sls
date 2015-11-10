include:
  - .ppa

unison:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - cmd: sao_backports_ppa
{% endif %}
