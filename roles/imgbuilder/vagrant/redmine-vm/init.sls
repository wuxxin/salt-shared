include:
  - git
  - vagrant
  - rbenv
  - imgbuilder

redmine-vm-librarian-chef:
  gem.installed:
    - name: librarian-chef
    - user: imgbuilder
    - require:
      - gem: redmine-vm

redmine-vm-gusteau:
  gem.installed:
    - name: gusteau
    - user: imgbuilder
    - require:
      - gem: redmine-vm

redmine-vm:
  gem.installed:
    - name: bundler
    - user: imgbuilder
    - require:
      - user: imgbuilder
      - rbenv: local-ruby
  git.latest:
    - name:   https://github.com/dergachev/vagrant_redmine.git
    - target: /mnt/images/templates/imgbuilder/redmine-vm
    - runas: imgbuilder
    - submodules: True
    - require:
      - file: /mnt/images/templates/imgbuilder
      - gem: redmine-vm
      - gem: redmine-vm-librarian-chef
      - gem: redmine-vm-gusteau
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//redmine-vm/Vagrantfile
    - name: /mnt/images/templates/imgbuilder/redmine-vm/Vagrantfile
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - watch:
      - git: redmine-vm  
  cmd.wait:
    - name: cd /mnt/images/templates/imgbuilder/redmine-vm; librarian-chef install
    - user: imgbuilder
    - group: imgbuilder
    - watch:
      - git: redmine-vm
    - require:
      - pkg: vagrant
      - file: redmine-vm
      - file: gusteau_config
      - file: redmine-cheffile
      - cmd: vagrant_plugin_vagrant-omnibus
      - cmd: vagrant_plugin_gusteau

gusteau_config:
  file.managed:
    - source: salt://roles/imgbuilder/vagrant//redmine-vm/.gusteau.local.yml
    - name: /mnt/images/templates/imgbuilder/redmine-vm/.gusteau.local.yml
    - user: imgbuilder
    - group: libvirtd
    - template: jinja
    - watch:
      - git: redmine-vm  

redmine-cheffile:
  file.append:
    - name: /mnt/images/templates/imgbuilder/redmine-vm/Cheffile
    - text: |
        cookbook "redmine",
          :git => "https://github.com/dergachev/chef_redmine"
    - watch:
      - git: redmine-vm
