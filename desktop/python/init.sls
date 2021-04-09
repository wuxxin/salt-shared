{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install %}

include:
  - python.dev

{# python code formating/linting/auditing tools #}
python-tools:
  pkg.installed:
    - pkgs:
      - isort             {# sort imports separated into sections #}
      - mypy              {# type check type annotations #}
      - yapf3             {# code audit and reformating #}
      - pylama            {# code audit and reformating for Python #}
      - python3-autopep8  {# autopep8 - code audit and reformating to PEP 8 style #}

{# install the following as pipx user package, so they are isolated from others #}

{# cookiecutter -  #}
{{ pipx_install('cookiecutter', user) }}

{# black - opinionated python source code formating #}
{{ pipx_install('black', user) }}

{# poetry - Python packaging and dependency management made easy #}
{{ pipx_install('poetry', user) }}

{# pipenv - Python Dev Workflow for Humans, to bring the best of all packaging worlds to the python world #}
{{ pipx_install('pipenv', user) }}


{# pyenv - easily switch between multiple versions of Python #}
{# FIXME: uses pyenv from git #}
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

{# # additional python shell packages
sh        # very elegant python shell
sarge     # python shell execute with "; &  | && || <>"
https://github.com/litl/rauth  # A Python library for OAuth 1.0/a, 2.0, and Ofly
#}
