include:
  - lab.appliance.zentyal.zentyal
  
{% from 'storage/lib.sls' import storage_setup %}

{% set var_list = ['backups', 'mail', 'tmp', 'vmail', 'www'] %}
{% set lib_list = ['amavis', 'clamav', 'mysql', 'postgrey', 'redis', 'spamassassin', 'zentyal'] %}
{% set spool_list =  ['postfix', 'sogo'] %}  

apparmor_alias:
  file.managed:
    - name: /etc/apparmor.d/tunables/alias.from.relocate
    - contents: |
        # Alias rules can be used to rewrite paths and are done after variable
        # resolution. For example: mysql database stored in /home:
        # alias /var/lib/mysql/ -> /home/mysql/,
        {%- for i in var_list %}
        alias /var/{{ i }}/ -> /opt/{{ i }}/,
        {%- endfor %}
        {%- for i in lib_list %}
        alias /var/lib/{{ i }}/ -> /opt/lib/{{ i }}/,
        {%- endfor %}
        {%- for i in spool_list %}
        alias /var/spool/{{ i }}/ -> /opt/spool/{{ i }}/,
        {%- endfor %}

{% load_yaml as custom_storage %}
directory:
  - name: /opt
    mountpoint: true
    require_in:
      - file: "directory_/opt/lib"
      - file: "directory_/opt/spool"
  - name: /opt/lib
    require:
      - pkg: zentyal
  - name: /opt/spool
    require:
      - pkg: zentyal
relocate:
  {%- for i in var_list %}  
  - source: /var/{{ i }}
    target: /opt/{{ i }}
    prereq_in:
      - cmd: pre_move_storage
    onchanges_in:
      - cmd: post_move_storage
    require:
      - file: "directory_/opt"
  {%- endfor %}
  {%- for i in lib_list %}  
  - source: /var/lib/{{ i }}
    target: /opt/lib/{{ i }}
    prereq_in:
      - cmd: pre_move_storage
    onchanges_in:
      - cmd: post_move_storage
    require:
      - file: "directory_/opt/lib"
  {%- endfor %}
  {%- for i in spool_list %}  
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

# make directories and relocate files
{{ storage_setup(custom_storage) }}

{% set stop_service_list  = "dovecot opendkim spamassassin clamav-freshclam redis mysql" %}
{% set start_service_list = "mysql redis clamav-freshclam spamassassin opendkim dovecot" %}

pre_move_storage:
  cmd.run:
    - name: |
        zs stop
        for i in {{ stop_service_list }}; do
            systemctl stop $i || true
        done
      
post_move_storage:
  cmd.run:
    - name: |
        cp -f /etc/apparmor.d/tunables/alias.from.relocate /etc/apparmor.d/tunables/alias
        systemctl reload apparmor
        for i in {{ start_service_list }}; do 
            systemctl start $i || true
        done
        zs start
    - require:
      - file: apparmor_alias

