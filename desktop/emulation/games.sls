{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("retroarch_ppa",
  "libretro/stable", require_in= "pkg: retroarch") }}
{{ apt_add_repository("pcsx2_ppa",
  "gregory-hainaut/pcsx2.official.ppa", require_in= "pkg: pcsx2") }}

retroarch:
  pkg:
    - installed

{% endif %}

pcsx2:
  pkg:
    - installed

mupen64plus:
  pkg:
    - installed
