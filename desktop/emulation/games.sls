{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu
{% endif %} 


pcsx2:
  pkg:
    - installed
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: pcsx2_ppa

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("pcsx2_ppa", "gregory-hainaut/pcsx2.official.ppa") }}

{% endif %}


mupen64plus:
  pkg:
    - installed

{% if grains['os'] == 'Ubuntu' %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("retroarch-ppa", "libretro/stable") }}

retroarch:
  pkg:
    - installed
    - require:
      - cmd: retroarch-ppa

{% endif %}

