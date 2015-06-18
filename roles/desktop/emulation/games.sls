{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 


pcsx2:
  pkg:
    - installed
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - pkgrepo: pcsx2
  pkgrepo.managed:
    - ppa: gregory-hainaut/pcsx2.official.ppa
{% endif %}


mupen64plus:
  pkg:
    - installed

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
retroarch:
  pkg:
    - installed
    - require:
      - pkgrepo: retroarch
  pkgrepo.managed:
    - ppa: libretro/stable
{% endif %}

