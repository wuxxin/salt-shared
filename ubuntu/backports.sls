include:
  - ubuntu

backport_repository:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: |
        ^deb http://archive.ubuntu.com/ubuntu {{ grains['oscodename'] }}-backports.*
    - repl: |
        deb http://archive.ubuntu.com/ubuntu {{ grains['oscodename'] }}-backports main restricted universe multiverse
    - append_if_not_found: true
  module.wait:
    - name: pkg.refresh_db
    - watch:
      - file: backport_repository

