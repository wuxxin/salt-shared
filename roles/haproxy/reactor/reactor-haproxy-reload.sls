haproxy-reload:
  cmd.state.highstate:
    - tgt: haproxy:status:enabled
    - expr_form: pillar

