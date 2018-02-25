include:
  - .base
  - .zentyal
  - .opendkim
{%- if salt['pillar.get']('appliance:zentyal:letsencrypt:enabled', false) %}
  - .letsencrypt
{% endif %}
  - .user

zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - require:
      - sls: .base
      - sls: .zentyal
      - sls: .user
      
