{% from 'storage/lib.sls' import storage_setup %}

# FIXME create user, group ebox beforehand

# make directories and relocate files
{% load_yaml as custom_storage %}
directory:
  - name: /opt
    mountpoint: true
  - name: /opt/var
    require:
      - file: "directory_/opt"
  {%- for i in ['backup', 'cache', 'lib', 'opt', 'snap', 'spool', 'www'] %}
  - name: /opt/var/{{ i }}
    require:
      - file: "directory_/opt/var"
  {%- endfor %}
  - name: /opt/var/crash
    mode: '1777'
    require:
      - file: "directory_/opt/var"
  - name: /opt/var/local
    group: staff
    mode: '2775'
    require:
      - file: "directory_/opt/var"
  - name: /opt/var/log
    group: syslog
    mode: '0775'
    require:
      - file: "directory_/opt/var"
  - name: /opt/var/mail
    group: mail
    mode: '2775'
    require:
      - file: "directory_/opt/var"
  - name: /opt/var/tmp
    mode: '1777'
    require:
      - file: "directory_/opt/var"
  - name: /opt/var/vmail
    user: ebox
    group: ebox
    require:
      - file: "directory_/opt/var"

relocate:
  {%- for i in ['backup', 'lib', 'mail', 'vmail'] %}
  - source: /var/{{ i }}
    target: /opt/var
    
    prereq_in:
      - cmd: pre_move_storage
    onchanges_in:
      - cmd: post_move_storage
    
    require:
      - file: "directory_/opt/var/{{ i }}"
  {%- endfor %}  

{% endload %}
{{ storage_setup(custom_storage) }}


{% set stop_service_list  = "apache2 dovecot opendkim spamassassin docker redis mysql atd cron" %}
{% set start_service_list = "cron atd mysql redis docker spamassassin opendkim dovecot apache2" %}


pre_move_storage:
  cmd.run:
    - name: zs stop; for i in {{ stop_service_list }}; do systemctl stop $i; done
      
post_move_storage:
  cmd.run:
    - name: for i in {{ start_service_list }}; do systemctl start $i; done; zs start
    