include:
  - .init

owncloud-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; vagrant up --no-provision
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: owncloud-vm

owncloud-vm-provision:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; vagrant provision 
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: owncloud-vm-up
