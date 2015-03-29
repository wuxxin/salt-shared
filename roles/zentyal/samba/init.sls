# ### postfix

{% if salt['pillar.get']('zentyal:samba:status', "absent") == "present" %} 

zentyal-samba:
  pkg.installed:
    - pkgs:
      - zentyal-samba
      - zentyal-antivirus
    - require:
      - pkg: zentyal

/etc/zentyal/hooks/samba.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/samba/samba.postsetconf
    - mode: 755
    - makedirs: true
    - template: jinja
    - context:
        modify_smb: {{ salt['pillar.get']('zentyal:samba:modify_smb', []) }}
        modify_shares: {{ salt['pillar.get']('zentyal:samba:modify_shares', []) }}
    - require:
      - pkg: zentyal-samba

restart_samba:
  cmd.wait:
    - name: service zentyal samba restart
    - watch:
      - file: /etc/zentyal/hooks/samba.postsetconf

{% endif %}
