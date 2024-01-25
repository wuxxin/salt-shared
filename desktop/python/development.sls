{% from 'python/lib.sls' import pipx_install %}
{% from 'desktop/user/lib.sls' import user with context %}
{% from 'arch/lib.sls' import aur_install with context %}

include:
  - python.dev


python_network_libraries:
  pkg.installed:
    - pkgs:
      # python-requests - Python HTTP for Humans
      - python-requests
      # websockets -  Python implementation of the WebSocket Protocol (RFC 6455)
      - python-websockets
      # paho-mqtt - Python client library for MQTT v3.1
      - python-paho-mqtt
      # python-grpcio - Python language bindings for grpc, remote procedure call (RPC) framework
      - python-grpcio

python_devices_libraries:
  pkg.installed:
    - pkgs:
      # sounddevice - Record and play back sound
      - python-sounddevice
      # pyserial - Multiplatform Serial Port Module for Python
      - python-pyserial
      # nfc - Python bindings for libnfc
      - python-nfc
      # bleak - cross platform Bluetooth Low Energy Client for Python using asyncio
      - python-bleak

python_devel_tools:
  pkg.installed:
    - pkgs:
      # cookiecutter - creates projects from cookiecutters project templates
      - python-cookiecutter
{% load_yaml as pkgs %}
      # micromamba - C++ tiny version of mamba, the fast conda package installer
      - micromamba
{% endload %}
{{ aur_install('python_devel_tools_aur', pkgs) }}

python_conversion_libraries:
  pkg.installed:
    - pkgs:
      # python-pdftotext - Simple PDF text extraction
      - python-pdftotext
      # python-html2text - HTML to markdown-structured text converter
      - python-html2text

python_linting_formatting:
  pkg.installed:
    - pkgs:
      ## python code formatting/linting/auditing/refactoring tools
      # mypy - type check type annotations
      - mypy
      # pyright - Type checker for the Python language
      - pyright
      # black - opinionated python source code formating
      - python-black
      # ruff - An extremely fast Python linter, written in Rust
      - ruff 
      # python-ruff - An extremely fast Python linter, written in Rust
      - python-ruff 
      # rope - Refactoring library
      - python-rope
      ## replaced formatting/linting/auditing/refactoring tools
      # yapf - code audit and reformating
      # - yapf
      # pylama - code audit and reformating
      # - pylama
      # isort - sort imports separated into sections
      # - python-isort
      # autopep8 - code audit and reformating to PEP 8 style
      # - autopep8
      # pylint - Analyzes Python code looking for bugs and signs of poor quality
      # - python-pylint

python_tools_lsp:
  pkg.installed:
    - pkgs:
      ## language server and languages
      # python-lsp-server - Fork of the python-language-server project
      - python-lsp-server
      # python-lsp-jsonrpc - Fork of the python-jsonrpc-server project
      - python-lsp-jsonrpc
      # python-lsp-black - Fork of pyls-black, black autoformatter language server
      - python-lsp-black
      # bash-language-server - bash language server implementation
      - bash-language-server
      # yaml-language-server - YAML Language Server
      - yaml-language-server
{% load_yaml as pkgs %}
      ## language server languages
      # python-lsp-ruff - python-lsp-server plugin for extensive and fast linting using ruff
      - python-lsp-ruff
      # python-pylsp-mypy - Static type checking for python-lsp-server with mypy
      - python-pylsp-mypy
      # python-pylsp-rope - Extended refactoring capabilities for Python LSP Server using Rope
      - python-pylsp-rope
      # dockerfile-language-server - Language server for Dockerfiles
      - dockerfile-language-server
      # cmake-language-server - Python based cmake language server
      - cmake-language-server
{% endload %}
{{ aur_install('python_tools_lsp_aur', pkgs,
    require='pkg: python_tools_lsp') }}


# python_tools_pipx
