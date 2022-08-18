{% from 'python/lib.sls' import pipx_install %}
{% from 'desktop/user/lib.sls' import user with context %}

include:
  - python.dev

# pipenv - Python Dev Workflow for Humans
{{ pipx_install('pipenv', user=user) }}

python_ide:
  pkg.installed:
    - pkgs:
      # pycharm-community-edition - Python IDE for Professional Developers
      - pycharm-community-edition
  
python_desktop:
  pkg.installed:
    - pkgs:
      ## python code formating/linting/auditing/refactoring tools
      # mypy - type check type annotations
      - mypy
      # yapf - code audit and reformating
      - yapf
      # pylama - code audit and reformating
      - pylama
      # isort - sort imports separated into sections
      - python-isort
      # autopep8 - code audit and reformating to PEP 8 style
      - autopep8
      # cookiecutter - creates projects from cookiecutters project templates
      - python-cookiecutter
      # black - opinionated python source code formating
      - python-black
      # rope - Refactoring library
      - python-rope
      # pyright - Type checker for the Python language
      - pyright
      # pylint - Analyzes Python code looking for bugs and signs of poor quality
      - python-pylint

      ## python environment tools
      # pyenv - Easily switch between multiple versions of Python
      - pyenv
      # poetry - Python packaging and dependency management made easy
      - python-poetry

python_other:
  pkg.installed:
    - pkgs:
      - python-websockets
      - python-sounddevice
