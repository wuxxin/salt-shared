include:
  - .ppa
{% if pillar.get('desktop.commercial.status', 'absent') == 'present' %}
  - .skype
{% endif %}


mumble:
  pkg.installed:
    - require:
      - cmd: mumble-ppa

jitsi:
  pkg.installed:
    - require:
      - cmd: jitsi-ppa

linphone:
  pkg:
    - installed

