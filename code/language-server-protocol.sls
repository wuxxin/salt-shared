# {% from 'arch/lib.sls' import aur_install with context %}
include:
  - code.python

lsp_server:
  pkg.installed:
    - pkgs:
      ## language server and languages
      # python-lsp-server - Fork of the python-language-server project
      - python-lsp-server
      # python-lsp-black - Fork of pyls-black, black autoformatter language server
      - python-lsp-black
      # bash-language-server - bash language server implementation
      - bash-language-server
      # vscode-css-languageserver - CSS and SCSS support
      - vscode-css-languageserver
      # vscode-html-languageserver - HTML language support
      - vscode-html-languageserver
      # vscode-json-languageserver - JSON language support
      - vscode-json-languageserver
      # ruff-lsp - Language Server Protocol implementation for Ruff
      - ruff-lsp
      # systemd-language-server - Language Server for Systemd unit files
      - systemd-language-server

# {% load_yaml as pkgs %}
      ## language server languages
      # pylyzer - fast static code analyzer & language server for Python
      - pylyzer
      # python-lsp-ruff - python-lsp-server plugin for extensive and fast linting using ruff
      - python-lsp-ruff
      # ty - An extremely fast Python type checker and language server, written in Rust
      - ty
      # basedpyright - pyright fork with various type checking improvements
      - basedpyright
      # python-pylsp-mypy - Static type checking for python-lsp-server with mypy
      - python-pylsp-mypy
      # openscad-lsp - A LSP server for OpenSCAD
      # - openscad-lsp
      # dockerfile-language-server - Language server for Dockerfiles
      # - dockerfile-language-server
      # cmake-language-server - Python based cmake language server
      # - cmake-language-server
# {% endload %}
# {{ aur_install('lsp_server_aur', pkgs, require='pkg: lsp_server') }}

