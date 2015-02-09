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
    - require:
      - pkg: zentyal-samba

{% endif %}
