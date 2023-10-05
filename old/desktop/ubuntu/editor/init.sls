include:
  - desktop.ubuntu.code
  - desktop.ubuntu.language.spellcheck

atom:
{% if grains['os_family'] == "Debian" %}
  pkgrepo.managed:
    - name: deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/{{ grains['os']|lower }}/ {{ grains['oscodename'] }} main
    - key_url: https://packagecloud.io/AtomEditor/atom/gpgkey
    - file: /etc/apt/sources.list.d/atom-packagecloud.io.list
    - require_in:
      - pkg: atom
{% endif %}
  pkg.installed:
    - name: atom
