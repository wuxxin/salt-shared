snapshot_backup-config-update:
  local.cmd.state.sls:
    - tgt: snapshot_backup:host:status:present
    - expr_form: pillar
    - name: roles.snapshot_backup.host.config_update.sls
    - pillar:
      snapshot_backup:
        update:
          minion: {{ data.id }}
          status: {{ data.status }}
          config: {{ data.config }}
