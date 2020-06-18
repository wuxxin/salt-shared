{% from "old/lab/appliance/zentyal/defaults.jinja" import settings with context %}
include:
  - old.lab.appliance.zentyal.base
  - old.lab.appliance.zentyal.zentyal
  - old.lab.appliance.zentyal.opendkim
{%- if settings.letsencrypt.enabled %}
  - old.lab.appliance.zentyal.letsencrypt
{% endif %}
  {#- old.lab.appliance.zentyal.storage#}
  - old.lab.appliance.zentyal.user

zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - onlyif: test -e /var/lib/zentyal/.first
    - require:
      - sls: old.lab.appliance.zentyal.base
      - sls: old.lab.appliance.zentyal.zentyal
      {#- sls: old.lab.appliance.zentyal.storage #}
      - sls: old.lab.appliance.zentyal.user
