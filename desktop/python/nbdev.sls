{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.jupyter

{{ pipx_inject('jupyterlab', [ 'nbdev', ], pipx_opts='--include-apps',
  require='sls: desktop.python.jupyter', user=user) }}
