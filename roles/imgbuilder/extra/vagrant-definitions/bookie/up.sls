include:
  - .init

bookie-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/bookie-vm; vagrant up
    - runas: imgbuilder
    - require:
      - cmd: bookie-vm


