include:
  - desktop.code
  - desktop.language.spellcheck

atom:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main
    - key_url: https://packagecloud.io/AtomEditor/atom/gpgkey
    - file: /etc/apt/sources.list.d/atom-packagecloud.io.list
    - require_in:
      - pkg: atom
  pkg.installed:
    - name: atom
