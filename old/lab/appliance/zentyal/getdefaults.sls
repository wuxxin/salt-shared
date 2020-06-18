{% from "old/lab/appliance/zentyal/defaults.jinja" import settings with context %}

loaded_settings:
  test.nop:
    - contents: |
{{ settings|yaml(False)|indent(6,True) }}

