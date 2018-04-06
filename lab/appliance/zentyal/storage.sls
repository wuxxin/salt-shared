{% from 'storage/lib.sls' import storage_setup %}

# make directories and relocate files
{% load_yaml as custom_storage %}
directory:
  - name: /opt
    mountpoint: true
    require_in:
      - file: "directory_/opt/lib"
      - file: "directory_/opt/spool"
  - name: /opt/lib
  - name: /opt/spool
relocate:
  {%- for i in ['backups', 'mail', 'tmp', 'vmail', 'www'] %}  
  - source: /var/{{ i }}
    target: /opt/{{ i }}
    prereq_in:
      - cmd: pre_move_storage
    onchanges_in:
      - cmd: post_move_storage
    require:
      - file: "directory_/opt"
  {%- endfor %}
  {%- for i in ['amavis', 'clamav', 'mysql', 'postgrey', 'redis', 'spamassassin', 'zentyal'] %}  
  - source: /var/lib/{{ i }}
    target: /opt/lib/{{ i }}
    prereq_in:
      - cmd: pre_move_storage
    onchanges_in:
      - cmd: post_move_storage
    require:
      - file: "directory_/opt/lib"
  {%- endfor %}
  {%- for i in ['postfix', 'sogo'] %}  
  - source: /var/spool/{{ i }}
    target: /opt/spool/{{ i }}
    prereq_in:
      - cmd: pre_move_storage
    onchanges_in:
      - cmd: post_move_storage
    require:
      - file: "directory_/opt/spool"
  {%- endfor %}
{% endload %}
{{ storage_setup(custom_storage) }}


{% set stop_service_list  = "dovecot opendkim spamassassin clamav-freshclam redis mysql" %}
{% set start_service_list = "mysql redis clamav-freshclam spamassassin opendkim dovecot" %}

pre_move_storage:
  cmd.run:
    - name: zs stop; for i in {{ stop_service_list }}; do systemctl stop $i; done
      
post_move_storage:
  cmd.run:
    - name: for i in {{ start_service_list }}; do systemctl start $i; done; zs start
