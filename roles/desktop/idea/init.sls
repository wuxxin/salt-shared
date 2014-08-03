include:
  - java.jdk

{% set idea_ver='IC-135.1146' %}

idea-standard:
  archive.extracted:
    - name: /opt/
    - source: http://download.jetbrains.com/idea/idea{{ idea_ver }}.tar.gz
    - source_hash: md5=4e9bc314d4ed9a1e18839ef661703aa5
    - archive_format: tar
    - tar_options: z
    - if_missing: /opt/idea-{{ idea_ver }}
    # 'IC-135.908'
    # md5=447fb91bea34e535e170949d42e8381e
    # 'IC-13.1.2'
    # md5=48daa326a1bce3666dbb06cedaf7b66a
  file.directory:
    - name: /opt/idea-{{ idea_ver }}/
    - user: root
    - group: users
    - recurse:
        - user
        - group
    - require:
      - archive: idea-standard

/usr/local/bin/idea:
  file.symlink:
    - target: /opt/idea-{{ idea_ver }}/bin/idea.sh
    - require: 
      - archive: idea-standard

