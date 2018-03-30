include:
  - .init

owncloud-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; vagrant up --no-provision
    - runas: imgbuilder
    - require:
      - cmd: owncloud-vm

owncloud-vm-provision:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; vagrant provision 
    - runas: imgbuilder
    - require:
      - cmd: owncloud-vm-up
