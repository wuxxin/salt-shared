include:
  - rvm
  - git

default-jre:
  pkg:
    - installed

veewee:
  group:
    - present
  user:
    - present
    - gid: veewee
    - home: /home/veewee
    - shell: /bin/bash
    - groups:
      - libvirtd
      - rvm
    - require:
      - group: veewee
      - group: rvm
  git.latest:
    - name: https://github.com/jedi4ever/veewee.git
    - target: /home/veewee/veewee
    - runas: veewee
    - submodules: True
    - require:
      - user: veewee
      - pkg: git
      - pkg: default-jre
  pkg.installed:
    - pkgs:
      - libxslt1-dev
      - libxml2-dev
      - zlib1g-dev
      - libvirt-dev
  rvm.gemset_present:
    - ruby: ruby-1.9.3
    - require:
      - rvm: ruby-1.9.3
  cmd.wait:
    - name: cd /home/veewee/veewee; chown veewee:veewee -R * .*; sudo -u veewee -i /bin/bash -l -c "rvm rvmrc load /home/veewee/veewee; cd /home/veewee/veewee; bundle install --without restrictions"
    - require:
      - rvm: veewee
      - pkg: veewee
      - file: /home/veewee/veewee/.rvmrc
      - file: disable_log4r
    - watch:
      - git: veewee

/home/veewee/veewee/.rvmrc:
  file.replace:
    - pattern: |
        ruby-1.9.2@veewee --create
    - repl: ruby-1.9.3@veewee --create
    - watch:
      - git: veewee

disable_log4r:
  file.comment:
    - name: /home/veewee/veewee/lib/veewee/provider/core/helper/winrm.rb
    - regex: ^[ ]+require 'log4r'
    - watch:
      - git: veewee
