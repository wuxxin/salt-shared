{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.python

development_fonts:
  pkg.installed:
    - pkgs:
      # nerd-fonts-complete - Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts
      - nerd-fonts-complete

development_ide:
  pkg.installed:
    - pkgs:
      - atom
      - ctags

{% load_yaml as pkgs %}
      ## editor
      # gnome-text-editor - Simple text editor that focuses on session management
      - gnome-text-editor
      # vscodium - Free/Libre Open Source Software Binaries of VSCode
      - vscodium
      - vscodium-features
      - vscodium-marketplacev
      # imhex - A Hex Editor for Reverse Engineers
      - imhex
{% endload %}
{{ pamac_install("development_ide_aur", pkgs) }}

development_tools:
  pkg.installed:
    - pkgs:
      ## conversion
      # pandoc - Conversion between markup formats, export to pdf
      - pandoc
      - pandoc-crossref
      ## encryption
      # age - simple, modern and secure file encryption tool
      - age
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
      ## devop tools
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
      # butane - Human readable Butane Configs into machine readable Ignition Configs
      - butane
{% endload %}
{{ pamac_install("development_tools_aur", pkgs) }}


development_languages:
  pkg.installed:
    - pkgs:
      - go
