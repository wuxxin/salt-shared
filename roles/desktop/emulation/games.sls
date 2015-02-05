{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 


pcsx2:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkgrepo: pcsx2
  pkgrepo.managed:
    - ppa: gregory-hainaut/pcsx2.official.ppa
{% endif %}


mupen64plus:
  pkg:
    - installed

{% if grains['os'] == 'Ubuntu' %}
retroarch:
  pkg:
    - installed
    - require:
      - pkgrepo: retroarch
  pkgrepo.managed:
    - ppa: libretro/stable
{% endif %}

