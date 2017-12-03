include:
  - python
  - tools
  - systemd.reload

{% from "ssh/lib.sls" import ssh_keys_update %}

/usr/local/share/appliance:
  file:
    - directory

{% for i in ['env.functions.sh', 'appliance.functions.sh',
 'prepare-env.sh', 'prepare-appliance.sh'] %}
/usr/local/share/appliance/{{ i }}:
  file.managed:
    - source: salt://appliance/scripts/{{ i }}
    - mode: "0755"
    - require:
      - sls: appliance
{% endfor %}

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
    
{% for n in ['tags', 'flags', 'hooks'] %}
create_app_etc_{{ n }}:
  file.directory:
    - name: /app/etc/{{ n }}
    - user: app
    - group: app
    - require:
      - file: /app/etc
{% endfor %}

{{ ssh_keys_update('app',
    salt['pillar.get']('ssh_authorized_keys', False),
    salt['pillar.get']('ssh_deprecated_keys', False)
    )
}}


{% for n in [
  'prepare-env.service', 'prepare-appliance.service', 
  'service-failed@.service',
  'mail-to-sentry.service', 'mail-to-sentry.path',
  ] %}
install_{{ n }}:
  file.managed:
    - name: /etc/systemd/system/{{ n }}
    - source: salt://appliance/systemd/{{ n }}
    - watch_in:
      - cmd: systemd_reload
{% endfor %}


install_appliance.service:
  file.managed:
    - name: /etc/systemd/system/appliance.service
    - source: salt://appliance/systemd/appliance.service
    - watch_in:
      - cmd: systemd_reload
  cmd.wait:
    - name: systemctl enable appliance.service
    - order: last
    - watch:
      - file: install_appliance.service
