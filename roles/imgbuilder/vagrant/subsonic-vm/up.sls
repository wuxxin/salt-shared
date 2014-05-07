include:
  - .init

subsonic-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/subsonic-vm; vagrant up --no-provision
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: subsonic-vm


subsonic-vm-provision:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/subsonic-vm; vagrant provision 
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: subsonic-vm-up
