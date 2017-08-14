include:
  - git
  - vagrant
  - rbenv
  - imgbuilder

owncloud-vm:
  gem.installed:
    - name: bundler
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - rbenv: local-ruby
  git.latest:
    - name: https://github.com/onddo/owncloud-cookbook.git
    - target: /mnt/images/templates/imgbuilder/owncloud-vm
    - user: imgbuilder
    - submodules: True
    - require:
      - file: /mnt/images/templates/imgbuilder
      - gem: owncloud-vm
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//owncloud-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/owncloud-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - mode: 664
    - template: jinja
    - watch:
      - git: owncloud-vm
  cmd.wait:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; bundle install
    - runas: imgbuilder
    - group: imgbuilder
    - watch:
      - git: owncloud-vm
    - require:
      - file: owncloud-vm
      - pkg: vagrant
      - cmd: vagrant_plugin_vagrant-omnibus
      - cmd: vagrant_plugin_vagrant-berkshelf
      - file: owncloud_berkshelf-config
      - file: owncloud_berksfile

owncloud_berkshelf-config:
  file.managed:
    - name: /mnt/images/templates/imgbuilder/owncloud-vm/.berkshelf/config.json
    - source: salt://roles/imgbuilder/vagrant//owncloud-vm/config.json
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - require:
      - git: owncloud-vm

owncloud_berksfile:
  file.sed:
    - name: /mnt/images/templates/imgbuilder/owncloud-vm/Berksfile
    - before: 'site :opscode'
    - after: 'source "http://api.berkshelf.com"'
    - user: imgbuilder
    - require:
      - git: owncloud-vm
