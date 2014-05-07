ttrss-vm-destroy:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/ttrss-vm; vagrant destroy
    - user: imgbuilder
    - group: imgbuilder

/mnt/images/templates/imgbuilder/ttrss-vm:
  file.absent:
    - require: 
      - cmd: ttrss-vm-destroy

