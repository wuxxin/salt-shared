include:
  - locale
  - timezone
  - ubuntu.server
  - ubuntu.backports
  - ssh
  - python
  - tools
  
ca-certificates:
  pkg:
    - installed

/usr/local/share/appliance:
  file:
    - directory
        
application_user:
  group.present:
    - name: app
  user.present:
    - name: app
    - gid: app
    - home: /app
    - shell: /bin/bash
    - remove_groups: False
  file.directory:
    - name: /app/.ssh
    - user: app
    - group: app
    - dir_mode: 700
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: application_user

{% for i in ".bash_logout", ".bashrc", ".profile" %}
application_skeleton_{{ i }}:
  file.copy:
    - name: /app/{{ i }}
    - source: /etc/skel/{{ i }}
    - user: app
    - group: app
    - unless: test /app/{{ i }} -nt /etc/skel/{{ i }}
    - require:
      - user: application_user
{% endfor %}

/app/etc:
  file.directory:
    - user: app
    - group: app

/var/www/html:
  file.directory:
    - makedirs: true
    
/app/etc/app-template.html:
  file.managed:
    - source: salt://appliance/app-template.html

{% for n in ['tags', 'flags', 'hooks'] %}
create_app_etc_{{ n }}:
  file.directory:
    - name: /app/etc/{{ n }}
    - user: app
    - group: app
    - require:
      - file: /app/etc
{% endfor %}

{% from "ssh/lib.sls" import ssh_keys_update %}
{{ ssh_keys_update('app',
    salt['pillar.get']('ssh_authorized_keys', False),
    salt['pillar.get']('ssh_deprecated_keys', False)
    )
}}
