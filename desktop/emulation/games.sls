{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}

{{ apt_add_repository("retroarch-ppa", 
  "libretro/stable", require_in= "pkg: retroarch") }}

retroarch:
  pkg:
    - installed

{{ apt_add_repository("pcsx2_ppa", 
  "gregory-hainaut/pcsx2.official.ppa", require_in= "pkg: pcsx2") }}

{% endif %}

pcsx2:
  pkg:
    - installed

mupen64plus:
  pkg:
    - installed

