{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - python.dev
  - python.nbdev

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
    - name: https://github.com/pyenv/pyenv.git
    - target: {{ user_home }}/.pyenv
    - user: {{ user }}
    - submodules: True

pyenv_bashrc:
  file.blockreplace: {# XXX file.blockreplace does use "content" instead of "contents" #}
    - name: {{ user_home }}/.bashrc
    - marker_start: "# ### PYENV BEGIN ###"
    - marker_end: "# ### PYENV END ###"
    - append_if_not_found: True
    - runas: {{ user }}
    - content: |
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
