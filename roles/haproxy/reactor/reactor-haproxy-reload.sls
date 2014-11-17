haproxy-reload:
  cmd.state.highstate:
    - tgt: haproxy:status:present
    - expr_form: pillar

