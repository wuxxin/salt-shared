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

