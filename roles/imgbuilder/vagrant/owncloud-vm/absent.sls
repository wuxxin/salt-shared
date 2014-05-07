owncloud-destroy:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/owncloud-vm; vagrant destroy
    - user: imgbuilder
    - group: imgbuilder

/mnt/images/templates/imgbuilder/owncloud-vm:
  file.absent:
    - require: 
      - cmd: owncloud-destroy

