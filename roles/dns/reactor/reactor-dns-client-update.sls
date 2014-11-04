dns-client-update:
  cmd.state.sls:
    - tgt: dns:status:enabled
    - expr_form: pillar
    - name: roles.dns.server.update.sls
    - pillar:
      dns:
        update: {{ data.data }}
