include:
  - python
  - console-tools
  - console-tools.python
  - appliance.user

{% for i in ['env.include', 'appliance.include',
 'prepare-env.sh', 'prepare-appliance.sh'] %}
/usr/local/share/appliance/{{ i }}:
  file.managed:
    - source: salt://appliance/scripts/{{ i }}
    - mode: "0755"
    - require:
      - sls: appliance.user
{% endfor %}
