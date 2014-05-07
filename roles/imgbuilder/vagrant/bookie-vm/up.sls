include:
  - .init

bookie-vm-up:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/bookie-vm; vagrant up
    - user: imgbuilder
    - group: imgbuilder
    - require:
      - cmd: bookie-vm


