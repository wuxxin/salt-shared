include:
  - .user
  - .packer
  - .vagrant
  #- .local-ruby


/mnt/images/templates/imgbuilder:
  file.directory:
    - user: imgbuilder
    - group: libvirtd
    - mode: 775
    - makedirs: True
    - require:
      - user: imgbuilder

/mnt/images/templates/imgbuilder/scripts:
  file.recurse:
    - source: salt://roles/imgbuilder/scripts
    - user: imgbuilder
    - group: imgbuilder
    - file_mode: 775
    - makedirs: True
    - require:
      - file: /mnt/images/templates/imgbuilder

