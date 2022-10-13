{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro
  - desktop.manjaro.python
  - desktop.manjaro.emulator

development_languages:
  pkg.installed:
    - pkgs:
      - go
    - require:
      - sls: desktop.manjaro.python

development_fonts:
  pkg.installed:
    - pkgs:
      # nerd-fonts-complete - Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts
      - nerd-fonts-complete

development_ide:
  pkg.installed:
    - pkgs:
      # pycharm-community-edition - Python IDE for Professional Developers
      - pycharm-community-edition

{% load_yaml as pkgs %}
      # gnome-text-editor - Simple text editor that focuses on session management
      - gnome-text-editor
      # vscodium - Free/Libre Open Source Software Binaries of VSCode
      - vscodium
      - vscodium-features
      - vscodium-marketplace
      # imhex - A Hex Editor for Reverse Engineers
      - imhex
{% endload %}
{{ pamac_install("development_ide_aur", pkgs) }}

development_tools:
  pkg.installed:
    - pkgs:
      ## linter/beautifier
      # shfmt - Format shell programs
      - shfmt

      ## filter
      # go-yq - Portable command-line YAML processor
      - go-yq

      ## encryption
      # age - simple, modern and secure file encryption tool
      - age
      # minisign - A dead simple tool to sign files and verify digital signatures
      - minisign

      ## conversion
      # pandoc - Conversion between markup formats, export to pdf
      - pandoc
      - pandoc-crossref

      ## updates
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

      ## terminal
      # wezterm - GPU-accelerated cross-platform terminal emulator and multiplexer
      - wezterm
      # kitty - modern, hackable, featureful, OpenGL-based terminal emulator
      - kitty

      ## filemanager
      # nnn - The fastest terminal file manager ever written
      - nnn
      # bat - Cat clone with syntax highlighting and git integration
      - bat
      # mediainfo - Supplies technical and tag information about a video or audio
      - mediainfo
      # elinks - advanced and well-established feature-rich text mode web browser
      - elinks

{% load_yaml as pkgs %}
      ## filter
      # yj - Convert YAML <=> TOML <=> JSON <=> HCL
      - yj
      ## security
      # mfoc - MiFare Classic Universal toolKit
      - mfoc
{% endload %}
{{ pamac_install("development_tools_aur", pkgs) }}


devop_tools:
  pkg.installed:
    - pkgs:
      ## devop
      # vault - A tool for managing secrets
      - vault
      # step-cli - A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc.
      - step-cli
      # fping - Utility to ping multiple hosts at once
      - fping
      # nmap - Utility for network discovery and security auditing
      - nmap

{% load_yaml as pkgs %}
      ## devop
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
      # butane - Human readable Butane Configs into machine readable Ignition Configs
      - butane
      # pixiecore - An all-in-one tool for easy netbooting (ftfp,dhcp-netboot,http)
      - pixiecore-git
      # flent - The FLExible Network Tester
      - flent
      # vault - command line tool for Hashicorp Vault
      - vault-cli
      ## security
      # mfoc - MiFare Classic Universal toolKit
      - mfoc
{% endload %}
{{ pamac_install("devop_tools_aur", pkgs) }}


{% load_yaml as pkgs %}
      ## mkdocs - Project documentation with Markdown
      - mkdocs
      ## plugins
      # lunr - to prebuild search index
      - python-lunr
      - mkdocs-git-revision-date-localized-plugin
      - mkdocs-with-pdf
      - mkdocs-ezlinks-plugin
      - mkdocs-rss-plugin
      - mkdocs-mermaid2-plugin
      - mkdocs-redirects
      ## themes
      - mkdocs-cinder
      - mkdocs-bootswatch
      # FIXME: python-hatch-nodejs-version is currently not in manjaro community
      - python-hatch-nodejs-version
      - mkdocs-material
      - mkdocs-material-extensions
      - mkdocs-material-pymdownx-extras
{% endload %}
{{ pamac_install('development_docs_aur', pkgs) }}
