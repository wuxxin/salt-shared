include:
  - appliance.base
  
{% for i in ['env.functions.sh', 'appliance.functions.sh',
 'env-prepare.sh', 'appliance-prepare.sh'] %}
/usr/local/share/appliance/{{ i }}:
  file.managed:
    - source: salt://appliance/scripts/{{ i }}
    - mode: "0755"
    - require:
      - sls: appliance.base
{% endfor %}

{% for i in ['env-create.sh', 'env-update.sh'] %}
/usr/local/sbin/{{ i }}:
  file.managed:
    - source: salt://appliance/scripts/{{ i }}
    - mode: "0755"
{% endfor %}

{% for flag in salt['pillar.get']('appliance:flags:enabled', []) %}
flag_enable_{{ flag }}:
  file.managed:
    - name: /app/etc/flags/{{ flag }}
    - contents: ""
    
{% endfor %}

{% for flag in salt['pillar.get']('appliance:flags:disabled', []) %}
flag_disable_{{ flag_enable }}:
  file.absent:
    - name: /app/etc/flags/{{ flag }}
{% endfor %}

