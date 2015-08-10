{% if (grains['os'] == 'Ubuntu') %}

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
