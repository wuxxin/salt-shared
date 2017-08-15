include:
  - vcs.git
  - vagrant
  - rbenv
  - imgbuilder

dokku-vm:
  gem.installed:
    - name: bundler
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - rbenv: local-ruby
  git.latest:
    - name: https://github.com/dokku-alt/dokku-alt
    - target: /mnt/images/templates/imgbuilder/dokku-vm
    - user: imgbuilder
    - submodules: True
    - require:
      - gem: dokku-vm
      - file: /mnt/images/templates/imgbuilder
  file.managed:
    - source: salt://roles/imgbuilder/vagrant/dokku-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/dokku-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - require:
      - file: /mnt/images/templates/imgbuilder
  cmd.wait:
    - name: cd /mnt/images/templates/imgbuilder/dokku-vm
    - runas: imgbuilder
    - watch:
      - git: dokku-vm
    - require:
      - pkg: vagrant
      - file: dokku-vm
      - cmd: vagrant_plugin_vagrant-omnibus
      - cmd: vagrant_plugin_vagrant-berkshelf
      - cmd: vagrant_plugin_vagrant-bindfs

