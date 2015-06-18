include:
  - .ppa
{% if pillar.get('desktop.commercial.status', 'absent') == 'present' %}
  - .skype
{% endif %}


mumble:
  pkg.installed:
    - require:
      - pkgrepo: mumble-ppa

jitsi:
  pkg.installed:
    - require:
      - pkgrepo: jitsi-ppa

linphone:
  pkg:
    - installed

