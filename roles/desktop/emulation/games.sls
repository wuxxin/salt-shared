{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu
{% endif %} 


pcsx2:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: pcsx2_ppa

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("pcsx2_ppa", "gregory-hainaut/pcsx2.official.ppa") }}

{% endif %}


mupen64plus:
  pkg:
    - installed

{% if grains['os'] == 'Ubuntu' %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("retroarch-ppa", "libretro/stable") }}

retroarch:
  pkg:
    - installed
    - require:
      - cmd: retroarch-ppa

{% endif %}

