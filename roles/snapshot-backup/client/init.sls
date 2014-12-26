{% from "roles/snapshot-backup/client/defaults.jinja" import defaults with context %}
{% set settings=salt['grains.filter_by']({'none': defaults},
  grain='none', default= 'none', merge= salt['pillar.get']('snapshot-backup:client:config', {})) %}

update_config:
  event.fire_master:
    - name: "snapshot-backup/client/config-update"
    - data:
      status: present
      config: {{ settings }}
