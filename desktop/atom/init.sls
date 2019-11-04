include:
  - desktop.code
  - desktop.spellcheck
{% if grains['os'] == 'Ubuntu' %}
  - ubuntu
{% endif %}

atom:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main
    - key_url: https://packagecloud.io/AtomEditor/atom/gpgkey
    - file: /etc/apt/sources.list.d/atom-packagecloud.io.list
    - require:
      - sls: desktop.code
      - sls: desktop.spellcheck
{% if grains['os'] == 'Ubuntu' %}
      - pkg: ppa_ubuntu_installer
{% endif %}
    - require_in:
      - pkg: atom
  pkg.installed:
    - name: atom
