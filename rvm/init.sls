
rvm:
  group:
    - present
  user:
    - present
    - gid: rvm
    - shell: /bin/bash
    - home: /home/rvm
    - require:
      - group: rvm

ruby-1.9.3:
  rvm.installed:
    - default: True
    - require:
      - pkg: rvm-deps
      - pkg: mri-deps
      - user: rvm

rvm-deps:
  pkg.installed:
    - pkgs:
      - bash
      - curl
      - git
      - patch
      - bzip2
      - coreutils
      - gzip
      - gawk
      - sed
      - sudo

mri-deps:
  pkg.installed:
    - pkgs:
      - build-essential
      - openssl
      - libreadline6
      - libreadline6-dev
      - curl
      - git-core
      - zlib1g
      - zlib1g-dev
      - libssl-dev
      - libyaml-dev
      - libsqlite3-dev
      - sqlite3
      - libxml2-dev
      - libxslt1-dev
      - autoconf
      - libc6-dev
      - libgdbm-dev
      - libncurses5-dev
      - automake
      - libtool
      - bison
      - subversion
      - libffi-dev


