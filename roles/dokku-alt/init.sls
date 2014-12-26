include:
  - .ppa
  - docker

dokku-alt:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: dokku-alt
{% endif %}
  service.running:
    - require:
      - pkg: dokku-alt
