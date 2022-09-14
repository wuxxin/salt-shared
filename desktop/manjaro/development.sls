{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro
  - desktop.manjaro.python
  - desktop.manjaro.emulator

development_tools:
  pkg.installed:
    - pkgs:
      ## filter
      # go-yq - Portable command-line YAML processor
      - go-yq

      ## encryption
      # age - simple, modern and secure file encryption tool
      - age

      ## devop
      # step-cli - A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc.
      - step-cli

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
      # nnn - The fastest terminal file manager ever written.
      - nnn

{% load_yaml as pkgs %}
      ## devop
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
      # butane - Human readable Butane Configs into machine readable Ignition Configs
      - butane
      # pixiecore - An all-in-one tool for easy netbooting
      - pixiecore-git
{% endload %}
{{ pamac_install("development_tools_aur", pkgs) }}


development_languages:
  pkg.installed:
    - pkgs:
      - go

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
