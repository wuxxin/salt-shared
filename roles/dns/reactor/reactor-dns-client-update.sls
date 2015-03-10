dns-client-update:
  local.state.sls:
    - tgt: dns:status:present
    - expr_form: pillar
    - name: roles.dns.server.update.sls
    - pillar:
      dns:
        update: {{ data.data }}
