{% from 'desktop/user/lib.sls' import user, user_info, user_home, user_desktop with context %}
{% from 'code/python/lib.sls' import pipx_install, pipx_inject %}

include:
  - desktop.ubuntu.python
  - nodejs

{{ pipx_install('jupyterlab', require=['sls: code.python.dev', 'sls: nodejs'], user=user) }}

{# jupyterlab kernels, widgets, extensions #}
{{ pipx_inject('jupyterlab', [
  'jupyter', 'jupyter_server',
  'xeus-python',
  'sshkernel',
  'jupyter_micropython_kernel',
  'jupyterlab-notifications',
  'jupyterlab_widgets',
  'ipywebrtc',
  'jupyterlab-git',
  'jupyter-resource-usage',
  'retrolab',
  ], user=user) }}
{#  'xeus-sqlite', 'xonsh[full]' , 'jupyterlab-tabular-data-editor', #}

{# jupyterlab extension language server #}
{{ pipx_inject('jupyterlab', [
  'jupyterlab-lsp', 'jupyter-lsp', 'python-lsp-server[all]',
  'pyls-isort', 'python-lsp-black', 'pyls-memestra', 'mypy-ls', 'pyls-flake8',
  ], user=user) }}

{# scientific python stack #}
{{ pipx_inject('jupyterlab', [
  'scipy', 'numpy', 'matplotlib', 'plotly', 'bokeh', 'pandas',
  'xarray', 'hvplot', 'pandas-bokeh', 'pillow', 'seaborn', 'altair',
  'datashader', 'holoviews', 'panel', 'scikit-image', 'pyviz-comms',
  ], user=user) }}

{# jupyterlab extensions with cmdline tools #}
{{ pipx_inject('jupyterlab', [
  'jupytext', 'nbterm', 'nbdev',
 ], pipx_opts='--include-apps', user=user) }}

{# jupyterlab desktop entry #}
{% load_yaml as yupyter_desktop %}
Type: Application
Name: Jupyter-Lab
Exec: jupyter-lab
Path: {{ user_home }}
Comment: Jupyter Scientific Lab
Terminal: "true"
Icon: python3
Categories: Development;Science;
{% endload %}

{{ user_desktop(user, 'jupyterlab', yupyter_desktop) }}
