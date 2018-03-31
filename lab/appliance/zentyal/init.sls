include:
  - lab.appliance.zentyal.base
  - lab.appliance.zentyal.zentyal
  - lab.appliance.zentyal.opendkim
{%- if salt['pillar.get']('appliance:zentyal:letsencrypt:enabled', false) %}
  - lab.appliance.zentyal.letsencrypt
{% endif %}
  - lab.appliance.zentyal.user

zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - require:
      - sls: lab.appliance.zentyal.base
      - sls: lab.appliance.zentyal.zentyal
      - sls: lab.appliance.zentyal.user
      
