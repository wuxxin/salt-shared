include:
  - python.dev

## python code formating/linting/auditing tools
python_desktop:
  pkg.installed:
    - pkgs:
      - mypy
      # mypy - type check type annotations
      - yapf
      # yapf - code audit and reformating
      - pylama
      # pylama - code audit and reformating
      - python-isort
      # isort - sort imports separated into sections
      - autopep8
      # autopep8 - code audit and reformating to PEP 8 style
      - python-cookiecutter
      # cookiecutter - creates projects from cookiecutters project templates
      - python-black
      # black - opinionated python source code formating
      - python-poetry
      # poetry - Python packaging and dependency management made easy
      - python-pipenv
      # pipenv - Python Dev Workflow for Humans
      - python-rope
      # rope - Refactoring library
      - pyright
      # pyright - Type checker for the Python language
      - python-pylint
      # pylint - Analyzes Python code looking for bugs and signs of poor quality
      - pyenv
      # pyenv - Easily switch between multiple versions of Python

python_other:
  pkg.installed:
    - pkgs:
      - python-websockets
      - python-sounddevice
