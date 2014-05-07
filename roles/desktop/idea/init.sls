include:
  - java.jdk


idea-standard:
  archive.extracted:
    - name: /opt/
    - source: http://download.jetbrains.com/idea/ideaIC-13.1.2.tar.gz
    - source_hash: md5=48daa326a1bce3666dbb06cedaf7b66a
    - archive_format: tar
    - tar_options: z
    - if_missing: /opt/idea-IC-135.690
  file.directory:
    - name: /opt/idea-IC-135.690/
    - user: root
    - group: users
    - recurse:
        - user
        - group
    - require:
      - archive: idea-standard

/usr/local/bin/idea:
  file.symlink:
    - target: /opt/idea-IC-135.690/bin/idea.sh
    - require: 
      - archive: idea-standard

