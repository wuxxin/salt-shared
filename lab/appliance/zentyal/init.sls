{% from "lab/appliance/zentyal/defaults.jinja" import settings with context %}
include:
  - lab.appliance.zentyal.base
  - lab.appliance.zentyal.zentyal
  - lab.appliance.zentyal.opendkim
{%- if settings.letsencrypt.enabled %}
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
      
