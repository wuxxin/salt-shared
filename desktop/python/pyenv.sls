include:
  - python.dev

{% if grains['os'] == 'Ubuntu' %}
  {% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{# pyenv - easily switch between multiple versions of Python #}
pyenv:
  pkg.installed:
    - pkgs:
      - libssl-dev
      - zlib1g-dev
      - libbz2-dev
      - libreadline-dev
      - libsqlite3-dev
      - libncursesw5-dev
      - libxml2-dev
      - libxmlsec1-dev
      - libffi-dev
      - liblzma-dev
      - tk-dev
      - xz-utils
      - wget
      - curl
      - llvm
  {# FIXME use release tarball from github, eg. 1.2.27 #}
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

{% else %}

pyenv:
  pkg:
    - installed

{% endif %}
