include:
  - .ppa
  - java.browser

firefox:
  pkg.installed:
    - pkgs: 
      - firefox
      - firefox-dev
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - pkgrepo: firefox-dev_ppa
{% endif %}

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser

