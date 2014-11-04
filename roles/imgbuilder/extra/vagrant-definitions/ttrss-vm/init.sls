include:
  - git
  - vagrant
  - rbenv
  - imgbuilder

ttrss-vm:
  gem.installed:
    - name: bundler
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - rbenv: local-ruby
  git.latest:
    - name: https://github.com/kui/ttrss-test.git
    - target: /mnt/images/templates/imgbuilder/ttrss-vm
    - runas: imgbuilder
    - submodules: True
    - require:
      - gem: ttrss-vm
      - file: /mnt/images/templates/imgbuilder
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//ttrss-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/ttrss-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - watch:
      - git: ttrss-vm
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/ttrss-vm; bundle
    - user: imgbuilder
    - group: imgbuilder
    - watch:
      - git: ttrss-vm
    - require:
      - file: ttrss-vm
      - file: ttrss_ruby-version
      - file: ttrss_berksfile
      - pkg: vagrant
      - cmd: vagrant_plugin_vagrant-omnibus
      - cmd: vagrant_plugin_vagrant-berkshelf

/mnt/images/templates/imgbuilder/ttrss-vm/.berkshelf/config.json:
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//ttrss-vm/config.json
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - watch:
      - git: ttrss-vm

ttrss_berksfile:
  file.sed:
    - name: /mnt/images/templates/imgbuilder/ttrss-vm/Berksfile
    - before: 'site :opscode'
    - after: 'source "http://api.berkshelf.com"'
    - user: imgbuilder
    - require:
      - git: ttrss-vm

ttrss_ruby-version:
  file.sed:
    - name: /mnt/images/templates/imgbuilder/ttrss-vm/.ruby-version
    - before: '1.9.3-p448'
    - after: '1.9.3-p484'
    - user: imgbuilder
    - require:
      - git: ttrss-vm
