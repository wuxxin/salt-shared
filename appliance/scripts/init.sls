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
    - source: salt://common/{{ i }}
    - mode: "0755"
{% endfor %}