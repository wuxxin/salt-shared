empty-box:
  file.recurse:
    - source: salt://roles/imgbuilder/vagrant/empty-box
    - name: /mnt/images/templates/empty-box
    - user: imgbuilder
    - group: libvirtd
    - file_mode: 664
    - dir_mode: 775
    - include_empty: True
  cmd.run:
    - name: cd /mnt/images/templates/empty-box; ./vagrant-box-add.sh
    - user: imgbuilder
    - group: imgbuilder