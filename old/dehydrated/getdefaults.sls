{% from "dehydrated/defaults.jinja" import settings, letsencrypt with context %}

loaded_settings:
  test.nop:
    - contents: |
      dehydrated:
{{ settings|yaml(False)|indent(8,True) }}
      letsencrypt:
{{ letsencrypt|yaml(False)|indent(8,True) }}
        
      
