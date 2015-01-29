include:
  - .ppa
{% if pillar['desktop.commercial.status']|d('false') == 'present' %}
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

