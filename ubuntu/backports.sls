include:
  - ubuntu

backport_repository:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: |
        ^deb http://archive.ubuntu.com/ubuntu {{ grains['osname'] }}-backports.*
    - repl: |
        deb http://archive.ubuntu.com/ubuntu {{ grains['osname'] }}-backports main restricted universe multiverse
    - append_if_not_found: true
  pkg.refresh_db:
    - onchanges_in:
      - file: /etc/apt/sources.list

