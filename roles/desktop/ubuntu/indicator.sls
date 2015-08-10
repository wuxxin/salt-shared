{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

atareao_ppa:
  pkgrepo.managed:
    - ppa: atareao/atareao
    - file: /etc/apt/sources.list.d/atareao.list

"my-weather-indicator":
  pkg:
    - installed
    - require:
      - pkgrepo: atareao_ppa

indicator-multiload:
  pkg:
    - installed

{% endif %}
