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
      - cmd: firefox-dev_ppa
{% endif %}

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser

other-browser:
  pkg.installed:
    - pkgs:
      - midori
      - qupzilla
{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
    - require:
      - cmd: midori_ppa
      - cmd: qupzilla_ppa
{% endif %}
