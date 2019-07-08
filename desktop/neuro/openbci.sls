{#
https://github.com/OpenBCI/OpenBCI_GUI/releases
https://github.com/OpenBCI/OpenBCI_Hub/releases/latest
https://github.com/OpenBCI/OpenBCI_Python/releases/latest
{% set base= "https://github.com/mvdan/sh" %}
{% set version= salt['cmd.run_stdout'](
  'curl -L -s -o /dev/null -w "%{url_effective}" "'+ base+ '/releases/latest"'+
  '| sed -r "s/.*\\/v([^\\/]+)$/\\1/"', python_shell=true) %}
{% set name= "shfmt_v"+ version+ "_linux_amd64" %}
{% set source= base+ "/releases/download/v"+ version+ "/"+ name %}
{% set target= "/usr/local/src/"+ version+ "/"+ name %}

#}

{% from 'desktop/user/lib.sls' import user, user_info, user_home, add_to_groups with context %}

openbci-python:
  pkg.installed:
    - pkgs:
      - python3-numpy
      - python3-xmltodict
      - python3-wheel
      - python3-serial
      - python3-six
      - python3-socketio-client
      - python3-websocket
      - python3-requests
      - python3-yapsy

{{ pip3_install('pylsl', user=user) }}
{{ pip3_install('python-osc', user=user) }}
FIXME: needs git fork with some pull requests squashed or some time of waiting
{{ pip3_install('OpenBCI-Python', user=user) }}

