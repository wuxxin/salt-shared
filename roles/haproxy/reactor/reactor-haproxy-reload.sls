haproxy-reload:
  local.state.highstate:
    - tgt: haproxy:status:present
    - expr_form: pillar

