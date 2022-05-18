include:
  - python.dev

{# python code formating/linting/auditing tools #}
python_desktop:
  pkg.installed:
    - pkgs:
      - mypy
      {# type check type annotations #}
      - yapf
      {# code audit and reformating #}
      - pylama
      {# code audit and reformating #}
      - python-isort
      {# sort imports separated into sections #}
      - autopep8
      {# code audit and reformating to PEP 8 style #}
      - python-cookiecutter
      {# creates projects from cookiecutters project templates #}
      - python-black
      {# opinionated python source code formating #}
      - python-poetry
      {# Python packaging and dependency management made easy #}
      - python-pipenv
      {# Python Dev Workflow for Humans #}
      - python-rope
      {# Refactoring library #}
      - python-pylint
      {# Analyzes Python code looking for bugs and signs of poor quality #}
      - pyenv
      {# Easily switch between multiple versions of Python #}

python_other:
  pkg.installed:
    - pkgs:
      - python-websockets
      - python-sounddevice
