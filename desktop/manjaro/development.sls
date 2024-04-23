{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.python
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.iot
  - desktop.manjaro.security

language-asm:
  pkg.installed:
    - pkgs:
      # nasm - 80x86 assembler designed for portability and modularity
      - nasm

language-go:
  pkg.installed:
    - pkgs:
      - go

language-java:
  pkg.installed:
    - pkgs:
      - jdk-openjdk
      - java-rhino

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
      # bless - High-quality, full-featured hex editor
      - bless

{% load_yaml as pkgs %}
      # gnome-text-editor - Simple text editor that focuses on session management
      - gnome-text-editor
      # vscodium - Free/Libre Open Source Software Binaries of VSCode
      - vscodium
      - vscodium-features
      - vscodium-marketplace
      # ida-free - feature full dissassembler
      - ida-free
      # imhex - Hex Editor for Reverse Engineers
      - imhex-bin
{% endload %}
{{ aur_install("development-ide-aur", pkgs) }}

development-tools:
  pkg.installed:
    - pkgs:
      ## encryption
      # gnupg - Complete and free implementation of the OpenPGP standard
      - gnupg
      # Secure Sockets Layer toolkit - cryptographic utility
      - openssl
      # age - simple, modern and secure file encryption tool
      - age
      # minisign - A dead simple tool to sign files and verify digital signatures
      - minisign

      ## filter
      # go-yq - Portable command-line YAML processor
      - go-yq
      # ugrep - ultra fast grep with interactive TUI, fuzzy search, boolean queries, hexdumps and more
      - ugrep

      ## conversion
      # pandoc - Conversion between markup formats, export to pdf
      - pandoc-cli
      - pandoc-crossref
      # marp - Markdown Presentation Ecosystem
      - marp-cli
      # csvkit - suite of utilities for converting to and working with CSV
      - csvkit

      ## database
      # sqlitebrowser - GUI editor for SQLite databases
      - sqlitebrowser

      ## linter/beautifier
      # shfmt - Format shell programs
      - shfmt

      ## rpc
      # grpc - High performance, open source, general RPC framework that puts mobile and HTTP/2 first
      - grpc
      # gRPC protocol buffers cli
      - grpc-cli

      ## updates
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

      ## watch
      # urlwatch - Tool for monitoring webpages for updates
      - urlwatch

      ## terminal
      # tmux - terminal multiplexer like screen
      - tmux
      # wezterm - GPU-accelerated cross-platform terminal emulator and multiplexer
      - wezterm
      # kitty - modern, hackable, featureful, OpenGL-based terminal emulator
      - kitty
      # vhs - A tool for recording terminal GIFs
      - vhs

      ### manager
      # nnn - The fastest terminal file manager ever written
      - nnn

      ### viewer
      # tokei - blazingly fast CLOC (Count Lines Of Code) program
      - tokei
      # viu - Simple terminal image viewer
      - viu
      # bat - Cat clone with syntax highlighting and git integration
      - bat
      # highlight - Fast and flexible source code highlighter
      - highlight
      # mediainfo - Supplies technical and tag information about a video or audio
      - mediainfo
      # elinks - advanced and well-established feature-rich text mode web browser
      - elinks

      ### network monitor
      - nload
      - bmon
      - iftop

      ### task management
      # pueue - task management for sequential and parallel execution of long-running tasks
      - pueue
{% load_yaml as pkgs %}
      ## filter
      # yj - Convert YAML <=> TOML <=> JSON <=> HCL
      - yj
      # glow - Command-line markdown renderer
      - glow
      # nautilus-checksums - Add checksums to Nautilus' properties window
      - nautilus-checksums
{% endload %}
{{ aur_install("development-tools-aur", pkgs) }}


devop-tools:
  pkg.installed:
    - pkgs:
      ## devop
      # jose - C-language implementation of Javascript Object Signing and Encryption
      - jose
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

{{ pacman_repo_key("selinux", "63191CE94183098689CAB8DB7EF137EC935B0EAF",
    "80862ce3e3de1cffa8f0a966c84a8f57296b1609f92d5696405bd2dcf038b819",
    owner="Jason Zaman <perfinion@gentoo.org>", user=user) }}

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
      # coreos-installer - Installer for CoreOS disk images
      - coreos-installer
      # pixiecore - An all-in-one tool for easy netbooting (ftfp,dhcp-netboot,http)
      - pixiecore-git
      # flent - The FLExible Network Tester
      - flent
      # vault - command line tool for Hashicorp Vault
      - vault-cli
      # fakepkg - reassembles installed packages from its delivered files (eg. while internet connection loss)
      - fakepkg
      # fakeroot-tcp - Tool for simulating superuser privileges,with tcp ipc
      - fakeroot-tcp
      # # selinux - SELinux
      # # SELinux module tools
      # - semodule-utils
      # - checkpolicy
{% endload %}
{{ aur_install("devop-tools-aur", pkgs, require="test: trusted-repo-flent") }}

