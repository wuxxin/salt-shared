# ### postfix

{% if salt['pillar.get']('zentyal:samba:status', "absent") == "present" %} 

/etc/zentyal/hooks/samba.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/samba/samba.postsetconf
    - mode: 755
    - require:
      - pkg: zentyal

{% endif %}
