{% if grains['os'] == 'Ubuntu' and grains['osmajorrelease'] >= 20 %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
include:
  - .framework

blueman-git:
  - pkg:
    - installed

{% endif %}

pulseaudio-tools:
  pkg.installed:
    - pkgs:
      - paprefs
      - pavucontrol
      - pavumeter
