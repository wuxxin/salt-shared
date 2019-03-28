{% set base= "https://github.com/mvdan/sh" %}
{% set version= salt['cmd.run_stdout'](
  'curl -L -s -o /dev/null -w "%{url_effective}" "'+ base+ '/releases/latest"'+
  '| sed -r "s/.*\\/v([^\\/]+)$/\\1/"', python_shell=true) %}
{% set name= "shfmt_v"+ version+ "_linux_amd64" %}
{% set source= base+ "/releases/download/v"+ version+ "/"+ name %}
{% set target= "/usr/local/src/"+ version+ "/"+ name %}

shfmt:
  file.managed:
    - name: {{ target }}
    - source: {{ source }}
    - skip_verify: true
    - makedirs: true
    - unless:
      - test -e {{ target }}

/usr/local/bin/shfmt:
  file.symlink:
    - target: {{ target }}
    
  