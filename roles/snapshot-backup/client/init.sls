update_config:
  event.fire_master:
    - name: "snapshot_backup/client/config-update"
    - data:
      status: present
      config: {{ salt['pillar.get']('snapshot_backup:client:config') }}
