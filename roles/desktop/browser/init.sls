include:
  - .ppa
  - java.browser

firefox:
  pkg.installed:
    - pkgs:
      - firefox
{% if grains['os'] == 'Ubuntu' %}
      - firefox-dev
      - firefox-esr
    - require:
      - cmd: firefox-dev_ppa
      - cmd: firefox-esr_ppa
{% endif %}

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser
