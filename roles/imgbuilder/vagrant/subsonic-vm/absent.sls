subsonic-vm-destroy:
  cmd.run:
    - name: cd /mnt/images/templates/imgbuilder/subsonic-vm; vagrant destroy
    - user: imgbuilder
    - group: imgbuilder

/mnt/images/templates/imgbuilder/subsonic-vm:
  file.absent:
    - require: 
      - cmd: subsonic-vm-destroy

