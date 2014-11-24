update_config:
  event.fire_master:
    - name: "snapshot-backup/client/config-update"
    - data:
      status: present
      config: {{ salt['pillar.get']('snapshot-backup:client:config') }}
