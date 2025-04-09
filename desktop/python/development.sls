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
      # python-dnspython - A DNS toolkit for Python
      - python-dnspython
      # paho-mqtt - Python client library for MQTT v3.1
      - python-paho-mqtt
      # python-grpcio - Python language bindings for grpc, remote procedure call (RPC) framework
      - python-grpcio
      # python-aiohttp - HTTP client/server for asyncio
      - python-aiohttp
      # python-aiosmtpd - An asyncio based SMTP server
      - python-aiosmtpd
{% load_yaml as pkgs %}
      # python-aiosmtplib - asyncio smtplib implementation
      - python-aiosmtplib
{% endload %}
{{ aur_install('python_network_libraries_aur', pkgs,
    require='pkg: python_network_libraries') }}

python_devices_libraries:
  pkg.installed:
    - pkgs:
      # sounddevice - Record and play back sound
      - python-sounddevice
      # pyserial - Multiplatform Serial Port Module for Python
      - python-pyserial
      # bleak - cross platform Bluetooth Low Energy Client for Python using asyncio
      - python-bleak
{% load_yaml as pkgs %}
      # getkey - Python library to easily read single chars and key strokes
      - python-getkey
      # nfc - Python bindings for libnfc
      - python-nfc
{% endload %}
{{ aur_install('python_devices_libraries_aur', pkgs,
    require='pkg: python_devices_libraries') }}

python_devel_tools:
  pkg.installed:
    - pkgs:
      # cookiecutter - creates projects from cookiecutters project templates
      - python-cookiecutter

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
      # rope - Refactoring library
      # - python-rope
