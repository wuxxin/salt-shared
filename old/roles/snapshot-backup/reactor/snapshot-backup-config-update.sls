snapshot-backup-config-update:
  local.state.sls:
    - tgt: snapshot-backup:host:status:present
    - expr_form: pillar
    - name: roles.snapshot-backup.host.config-update.sls
    - pillar:
      snapshot-backup:
        update:
          minion: {{ data.id }}
          status: {{ data.status }}
          config: {{ data.config }}
