mail-user-create:
  cmd.state.sls:
    - tgt: zentyal:mail:status:present
    - expr_form: pillar
    - name: roles.zentyal.server.user-create.sls
    - pillar:
      mail:
        create: {{ data.data }}
