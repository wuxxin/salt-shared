element-desktop:
{% if grains['os_family'] == "Debian" %}
  pkgrepo.managed:
    - name: deb https://packages.element.io/debian/ default main
    - key_url: https://packages.element.io/debian/element-io-archive-keyring.gpg
    - file: /etc/apt/sources.list.d/element_ppa.list
    - require_in:
      - pkg: element-desktop
{% endif %}
  pkg.installed:
    - name: element-desktop
