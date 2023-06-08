{% from 'aur/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.manjaro
  - desktop.python
  - desktop.manjaro.emulator
  - desktop.manjaro.iot
  - desktop.manjaro.security

language-go:
  pkg.installed:
    - pkgs:
      - go

language-rust:
  pkg.installed:
    - pkgs:
      - rust

# development-fonts:
#   pkg.installed:
#     - pkgs:
#       # nerd-fonts-complete - Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts
#       - nerd-fonts-complete

development-ide:
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
      # ida-free - feature full dissassembler
      - ida-free
{% endload %}
{{ aur_install("development-ide-aur", pkgs) }}

development-tools:
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

      ## database
      # sqlitebrowser - GUI editor for SQLite databases
      - sqlitebrowser

      ## updates
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

      ## terminal
      # wezterm - GPU-accelerated cross-platform terminal emulator and multiplexer
      - wezterm
      # kitty - modern, hackable, featureful, OpenGL-based terminal emulator
      - kitty
      ### manager
      # nnn - The fastest terminal file manager ever written
      - nnn
      ### viewer
      # viu - Simple terminal image viewer
      - viu
      # bat - Cat clone with syntax highlighting and git integration
      - bat
      # moc - ncurses console audio player designed to be powerful and easy to use
      - moc
      # mediainfo - Supplies technical and tag information about a video or audio
      - mediainfo
      # elinks - advanced and well-established feature-rich text mode web browser
      - elinks
      
{% load_yaml as pkgs %}
      ## filter
      # yj - Convert YAML <=> TOML <=> JSON <=> HCL
      - yj
      # browsh - a fully-modern text-based browser based on remote controlled firefox
      - browsh-bin
{% endload %}
{{ aur_install("development-tools-aur", pkgs) }}


devop-tools:
  pkg.installed:
    - pkgs:
      ## devop
      # mosquitto - Open Source MQTT Broker
      - mosquitto
      # vault - A tool for managing secrets
      - vault
      # step-cli - A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc.
      - step-cli
      # macchanger - small utility to change your NIC's MAC address
      - macchanger


{{ pacman_repo_key("flent", "DE6162B5616BA9C9CAAC03074A55C497F744F705", 
    "7ea640aad9ea799bef1bc04a5db884d0be8700c59b2be5f898ef35b9d7294f8a", user=user) }}

{% load_yaml as pkgs %}
      ## devop
      # mqttui - Subscribe to a MQTT Topic or publish  quickly from the terminal
      - mqttui
      # dns-lexicon - Manipulate DNS records on various DNS providers in a standardized/agnostic way
      - dns-lexicon
      # dnscontrol - Synchronize your DNS to multiple providers from a simple DSL
      - dnscontrol
      # q-dns - tiny command line DNS client with support for UDP, DoT, DoH, DoQ and ODoH
      - q-dns-git
      # butane - Human readable Butane Configs into machine readable Ignition Configs
      - butane
      # pixiecore - An all-in-one tool for easy netbooting (ftfp,dhcp-netboot,http)
      - pixiecore-git
      # flent - The FLExible Network Tester
      - flent
      # vault - command line tool for Hashicorp Vault
      - vault-cli
      # fakepkg - reassembles installed packages from its delivered files
      - fakepkg
      - fakeroot-tcp
{% endload %}
{{ aur_install("devop-tools-aur", pkgs, require="test: trusted-repo-flent") }}

