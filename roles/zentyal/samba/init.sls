# ### postfix

{% if pillar.zentyal.samba.status|d(absent) == "present" %}

/etc/zentyal/hooks/samba.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/samba/samba.postsetconf
    - mode: 755
    - require:
      - pkg: zentyal

{% endif %}
