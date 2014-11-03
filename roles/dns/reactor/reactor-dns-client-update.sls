dns-client-update:
  cmd.state.sls:
    - tgt: dns:status:enabled
    - expr_form: pillar
    - name: roles.odns.server.update.sls
    - pillar:
      dns:
        update: {{ data.data }}
