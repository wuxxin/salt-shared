include:
  - git
  - vagrant
  - rbenv
  - imgbuilder

subsonic-vm:
  gem.installed:
    - name: bundler
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - rbenv: local-ruby
  git.latest:
    - name: https://github.com/DarthNerdus/vagrant-subsonic
    - target: /mnt/images/templates/imgbuilder/subsonic-vm
    - runas: imgbuilder
    - submodules: True
    - require:
      - gem: subsonic-vm
      - file: /mnt/images/templates/imgbuilder
  file.managed:
    - source: salt://roles/imgbuilder/vagrant/subsonic-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/subsonic-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - watch:
      - git: subsonic-vm
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/subsonic-vm; bundle
    - user: imgbuilder
    - group: imgbuilder
    - watch:
      - git: subsonic-vm
    - require:
      - file: subsonic-vm
      - pkg: vagrant
      - cmd: vagrant_plugin_vagrant-omnibus
