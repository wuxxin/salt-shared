# ### samba

{% if salt['pillar.get']('appliance:zentyal:samba:status', "absent") == "present" %}

zentyal-samba:
  pkg.installed:
    - pkgs:
      - zentyal-antivirus
    - require:
      - pkg: zentyal

/var/lib/samba/private/dns_update_list.template:
  file.managed:
    - source: salt://lab/zentyal/samba/dns_update_list
    - mode: 644
    - require:
      - pkg: zentyal-samba

/var/lib/samba/private/dns_update_list.d:
  file.directory:
    - mode: 755
    - makedirs: true
    - clean: true
    - require:
      - pkg: zentyal-samba

/etc/zentyal/hooks/samba.postsetconf:
  file.managed:
    - source: salt://lab/zentyal/samba/samba.postsetconf
    - mode: 755
    - makedirs: true
    - template: jinja
    - context:
        modify_smb: {{ salt['pillar.get']('appliance:zentyal:samba:modify_smb', []) }}
        modify_shares: {{ salt['pillar.get']('appliance:zentyal:samba:modify_shares', []) }}
    - require:
      - pkg: zentyal-samba
      - file: /var/lib/samba/private/dns_update_list.template
      - file: /var/lib/samba/private/dns_update_list.d

  {% if pillar.appliance.zentyal.samba.homezone_include|d(False) != False %}
    {% for targetname,source in pillar.appliance.zentyal.samba.homezone_include.iteritems() %}
{{ targetname }}_zone_include:
  file.managed:
    - source: {{ source }}
    - name: /var/lib/samba/private/dns_update_list.d/{{ targetname }}
    - mode: 644
    - require:
      - file: /var/lib/samba/private/dns_update_list.template
      - file: /var/lib/samba/private/dns_update_list.d
    - watch_in:
      - cmd: restart_samba
    {% endfor %}
  {% endif %}

restart_samba:
  cmd.wait:
    - name: service zentyal samba restart
    - watch:
      - file: /etc/zentyal/hooks/samba.postsetconf

{% endif %}
