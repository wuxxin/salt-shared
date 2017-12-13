include:
  - .ppa
{% if salt['pillar.get']('desktop:commercial:enabled', false) == true %}
  - .skype
{% endif %}


mumble:
  pkg.installed:
    - require:
      - cmd: mumble_ppa

jitsi:
  pkg.installed:
    - require:
      - pkgrepo: jitsi_ppa

linphone:
  pkg:
    - installed

