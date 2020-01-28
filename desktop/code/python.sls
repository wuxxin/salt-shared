{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - python.dev
  
{# poetry - Python packaging and dependency management made easy #}
{# install poetry as pipx user package, so its isolated from others #}
poetry:
  cmd.run:
    - name: pipx install poetry
    - unless: pipx list | grep poetry -q 
    - runas: {{ user }}

{# pyenv - easily switch between multiple versions of Python #}
pyenv:
  git.latest:
    - name: {{ config.source.repo }}
    - target: {{ user_home }}/.pyenv
    - user: {{ config.user }}
    - submodules: True
    - runas: {{ user }}

pyenv_bashrc:
  file.blockreplace:
    -
    - content: |
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
  