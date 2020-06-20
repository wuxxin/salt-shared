/etc/apt/preferences.d/snapd-preference:
  file:
    - absent

snapd:
  pkg:
    - installed
    - require:
      - file: /etc/apt/preferences.d/snapd-preference
  service.running:
    - enable: true
    - unmask: true
    - require:
      - pkg: snapd
