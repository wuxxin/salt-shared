{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install %}

include:
  - python.dev
  - python.nbdev

{# poetry - Python packaging and dependency management made easy #}
{# install poetry as pipx user package, so its isolated from others #}
{{ pipx_install('poetry', user) }}

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

{#
python shell stuff
pip install sh        # very elegant python shell
pip install sarge     # python shell execute with "; &  | && || <>"
https://github.com/litl/rauth  # A Python library for OAuth 1.0/a, 2.0, and Ofly
pip install requests  # Python HTTP Requests for Humans
#}
