{% from 'manjaro/lib.sls' import pamac_install with context %}
{% from 'python/lib.sls' import pipx_install %}
{% from 'desktop/user/lib.sls' import user with context %}

include:
  - python.dev

python_tools_env:
  pkg.installed:
    - pkgs:
      # pipenv - Python Dev Workflow for Humans
      - python-pipenv
      # poetry - Python packaging and dependency management made easy
      - python-poetry
      # pyenv - Easily switch between multiple versions of Python
      - pyenv

python_tools_devel:
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

python_tools_lsp:
  pkg.installed:
    - pkgs:
      ## language server
      - python-lsp-server
      - python-lsp-black
      - python-lsp-jsonrpc
      - bash-language-server
      - yaml-language-server
{% load_yaml as pkgs %}
      ## language server: additional languages
      - dockerfile-language-server
      - python-pylsp-rope
{% endload %}
{{ pamac_install('python_tools_lsp_aur', pkgs,
    require='pkg: python_tools_lsp') }}

python_devices_libraries:
  pkg.installed:
    - pkgs:
      - python-sounddevice

python_network_libraries:
  pkg.installed:
    - pkgs:
      # requests - Python HTTP for Humans
      - python-requests
      # websockets -  Python implementation of the WebSocket Protocol (RFC 6455)
      - python-websockets
      # paho-mqtt - Python client library for MQTT v3.1
      - python-paho-mqtt
      # bleak - cross platform Bluetooth Low Energy Client for Python using asyncio
      - python-bleak
      # nfc - Python bindings for libnfc
      - python-nfc
