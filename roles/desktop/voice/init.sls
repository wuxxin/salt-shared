include:
  - .ppa

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

{% if pillar['desktop.commercial.binary.status']|d('false') == 'present' %}
skype:
  pkg:
    - installed
{% endif %}
