haproxy-client-update:
  local.state.sls:
    - tgt: haproxy:status:present
    - expr_form: pillar
    - name: roles.proxy.server.update.sls
    - pillar:
      haproxy:
        update: {{ data.data }}
