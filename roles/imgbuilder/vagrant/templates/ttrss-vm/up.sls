include:
  - .init

ttrss-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/ttrss-vm; vagrant up --no-provision
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: ttrss-vm


ttrss-vm-provision:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/ttrss-vm; vagrant provision 
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: ttrss-vm-up
