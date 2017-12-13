include:
  - ubuntu

backport_repository:
  file.replace:
    - name: /etc/apt/sources.list
    - pattern: |
        ^deb http://archive.ubuntu.com/ubuntu {{ grains['lsb_distrib_codename'] }}-backports.*
    - repl: |
        deb http://archive.ubuntu.com/ubuntu {{ grains['lsb_distrib_codename'] }}-backports main restricted universe multiverse
    - append_if_not_found: true
  module.run:
    - name: pkg.refresh_db
    - onchanges_in:
      - file: /etc/apt/sources.list

