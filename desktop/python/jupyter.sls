{% from 'python/lib.sls' import pipx_install, pipx_inject %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - python.dev

{{ pipx_install('jupyterlab', require='sls: python.dev', user=user) }}

{# jupyterlab extensions #}
{{ pipx_inject('jupyterlab', [
  'jupyter', 'jupyterlab-requirements', 'jupyterlab-notifications',
  'jupyterlab_widgets', 'jupyterlab-git',
  ], user=user) }}

{# jupyterlab language server #}
{{ pipx_inject('jupyterlab', [
  'jupyterlab-lsp', 'jupyter-lsp', 'python-lsp-server',
  'pyls-isort', 'python-lsp-black', 'pyls-memestra', 'mypy-ls', 'pyls-flake8',
  ], user=user) }}

{# scientific python #}
{{ pipx_inject('jupyterlab', [
  'scipy', 'numpy', 'matplotlib', 'plotly', 'bokeh', 'pandas',
  'xarray', 'hvplot', 'pandas-bokeh', 'pillow', 'seaborn', 'altair', 'geoviews',
  'datashader', 'holoviews', 'panel', 'scikit-image', 'pyviz_comms'
  ], user=user) }}
