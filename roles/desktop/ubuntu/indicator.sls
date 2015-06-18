{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

atareao_ppa:
  pkgrepo.managed:
    - ppa: atareao/atareao

"my-weather-indicator":
  pkg:
    - installed
    - require:
      - pkgrepo: atareao_ppa

{% endif %}

indicator-multiload:
  pkg:
    - installed

