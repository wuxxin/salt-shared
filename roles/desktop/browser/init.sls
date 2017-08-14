include:
  - .ppa
  - java.browser

firefox:
  pkg.installed:
    - pkgs:
      - firefox
      - firefox-dev
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - cmd: firefox-dev_ppa
{% endif %}

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser
