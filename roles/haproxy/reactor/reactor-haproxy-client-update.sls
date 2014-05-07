haproxy-client-update:
  cmd.state.sls:
    - tgt: haproxy:status:enabled
    - expr_form: pillar
    - name: roles.proxy.server.update.sls
    - pillar:
      haproxy:
        update: {{ data.data }}
