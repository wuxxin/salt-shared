{% from 'python/lib.sls' import pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python.scipy

{{ pipx_inject('scipy',
  ['ipython', 'ipykernel', 'jupyter', 'jupyterlab'],
  require='sls:python.user.scipy', user=user) }}
