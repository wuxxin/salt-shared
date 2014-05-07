include:
  - .init

redmine-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/redmine-vm; vagrant up; vagrant ssh -c 'sudo apt-get update; sudo apt-get install curl git vim -y'; gusteau converge production-vagrant
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: redmine-vm


