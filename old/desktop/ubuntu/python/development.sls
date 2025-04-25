{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'code/python/lib.sls' import pipx_install, pipx_inject %}

include:
  - code.python.dev
  - desktop.ubuntu.python.pyenv

{# python code formating/linting/auditing tools #}
python_desktop:
  pkg.installed:
    - pkgs:
      - mypy
      - yapf3
      - pylama
      - isort
      - python3-autopep8

{# install the following as pipx user package, so they are isolated from others #}
{% load_yaml as pkgs %}
      - cookiecutter
      - black
      - poetry
      - pipenv
{% endload %}
{% for i in pkgs %}
{{ pipx_install(i, user=user) }}
{% endfor %}
