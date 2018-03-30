include:
  - .init

update-guestfs-appliance:
  cmd.run:
    - require:
      - pkg: imgbuilder

