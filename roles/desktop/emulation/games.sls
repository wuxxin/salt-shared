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
    - file: /etc/apt/sources.list.d/gregory-hainaut-pcsx2.list

{% endif %}


mupen64plus:
  pkg:
    - installed

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
retroarch:
  pkgrepo.managed:
    - ppa: libretro/stable
    - file: /etc/apt/sources.list.d/libretro.list
  pkg:
    - installed
    - require:
      - pkgrepo: retroarch

{% endif %}

