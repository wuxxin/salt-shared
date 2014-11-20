include:
  - .ppa

salt-minion:
  pkg.installed:
    - require:
      - pkgrepo: salt_ppa
  service:
    - running
    - require:
      - pkg: salt-minion
      - pkg: psmisc
{% if grains['os'] == 'Debian' or grains['os'] == 'Ubuntu' %}
      - pkg: debconf-utils

debconf-utils:
  pkg:
    - installed
    - order: 1
{% endif %}

psmisc:
  pkg:
    - installed
    - order: 2

