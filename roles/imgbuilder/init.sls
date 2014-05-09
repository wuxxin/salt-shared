include:
  - .user
  - .local-ruby
  - .packer
  - .vagrant


/mnt/images/templates/imgbuilder:
  file.directory:
    - user: imgbuilder
    - group: libvirtd
    - mode: 775
    - makedirs: True
    - require:
      - user: imgbuilder
