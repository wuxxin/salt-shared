include:
  - appliance.base
  
{% for i in ['env.functions.sh', 'appliance.functions.sh',
 'prepare-env.sh', 'prepare-appliance.sh'] %}
/usr/local/share/appliance/{{ i }}:
  file.managed:
    - source: salt://appliance/scripts/{{ i }}
    - mode: "0755"
    - require:
      - sls: appliance.base
{% endfor %}

