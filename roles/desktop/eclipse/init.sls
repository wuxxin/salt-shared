include:
  - java.jdk

eclipse-standard:
  archive.extracted:
    - name: /opt/
    - source: http://ftp.fau.de/eclipse/technology/epp/downloads/release/kepler/SR2/eclipse-standard-kepler-SR2-linux-gtk-x86_64.tar.gz
    - source_hash: sha1=ef3be20a7c9abb05c9208c7796a4a2b79ffacdbb
    - archive_format: tar
    - tar_options: z
    - if_missing: /opt/eclipse

/usr/local/bin/eclipse:
  file.symlink:
    - target: /opt/eclipse/eclipse
    - require: 
      - archive: eclipse-standard

/opt/eclipse:
  file.directory:
    - user: root
    - group: users
    - recurse:
        - user
        - group
    - require:
      - archive: eclipse-standard
