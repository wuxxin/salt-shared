include:
  - git
  - vagrant
  - rbenv
  - imgbuilder

gitlab-vm:
  gem.installed:
    - name: bundler
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - rbenv: local-ruby
  git.latest:
    - name: https://gitlab.com/gitlab-org/cookbook-gitlab.git
    - target: /mnt/images/templates/imgbuilder/gitlab-vm
    - user: imgbuilder
    - submodules: True
    - require:
      - gem: gitlab-vm
      - file: /mnt/images/templates/imgbuilder
  file.managed:
    - source: salt://roles/imgbuilder/vagrant/gitlab-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/gitlab-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - require:
      - file: /mnt/images/templates/imgbuilder
  cmd.wait:
    - name: cd /mnt/images/templates/imgbuilder/gitlab-vm
    - user: imgbuilder
    - group: imgbuilder
    - watch:
      - git: gitlab-vm
    - require:
      - pkg: vagrant
      - file: gitlab-vm
      - cmd: vagrant_plugin_vagrant-omnibus
      - cmd: vagrant_plugin_vagrant-berkshelf
      - cmd: vagrant_plugin_vagrant-bindfs

