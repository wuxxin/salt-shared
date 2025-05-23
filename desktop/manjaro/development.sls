{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - code
  - desktop.python
  - desktop.manjaro
  - desktop.manjaro.emulator
  - desktop.manjaro.iot
  - desktop.manjaro.security

# development-fonts:
#   pkg.installed:
#     - pkgs:
#       # nerd-fonts-complete - Iconic font aggregator, collection, & patcher. 3,600+ icons, 50+ patched fonts
#       - nerd-fonts-complete

development-ide:
  pkg.installed:
    - pkgs:
      # code - The Open Source build of Visual Studio Code (vscode) editor
      - code
      # zed - high-performance, multiplayer code editor from the creators of Atom and Tree-sitter
      - zed
      # bless - High-quality, full-featured hex editor
      - bless

{% load_yaml as pkgs %}
      # code-features- Unblock some features in Code OSS
      - code-features
      # code-marketplace - Enable vscode marketplace in Code OSS
      - code-marketplace
      # gnome-text-editor - Simple text editor that focuses on session management
      - gnome-text-editor
      # ida-free - feature full dissassembler
      - ida-free
      # imhex - Hex Editor for Reverse Engineers
      - imhex-bin
{% endload %}
{{ aur_install("development-ide-aur", pkgs) }}

development-tools:
  pkg.installed:
    - pkgs:
      ## compression
      # upx - Extendable, high-performance executable packer for several executable formats
      - upx
      # 7zip - File archiver for extremely high compression
      - 7zip
      # xz - Library and command line tools for XZ and LZMA compressed files
      - xz

      ## conversion
      # pandoc - Conversion between markup formats, export to pdf
      - pandoc-cli
      - pandoc-crossref
      # poppler - PDF rendering library based on xpdf 3.0
      - poppler
      # imagemagick - An image viewing/manipulation program
      - imagemagick
      # pandoc pdfconversion needs lmodern.sty which is in texlive-fontrecommended
      - texlive-fontsrecommended
      # csvkit - suite of utilities for converting to and working with CSV
      - csvkit

      ## database
      # sqlitebrowser - GUI editor for SQLite databases
      - sqlitebrowser

      ## encryption
      # gnupg - Complete and free implementation of the OpenPGP standard
      - gnupg
      # Secure Sockets Layer toolkit - cryptographic utility
      - openssl
      # age - simple, modern and secure file encryption tool
      - age
      # minisign - A dead simple tool to sign files and verify digital signatures
      - minisign

      ### file-manager
      # nnn - The fastest terminal file manager ever written
      - nnn
      # yazi - Blazing fast terminal file manager written in Rust, based on async I/O
      - fd
      - fzf
      - zoxide
      - chafa
      - yazi

      ## filter
      # ripgrep - A search tool that combines the usability of ag with the raw speed of grep
      - ripgrep
      # ugrep - ultra fast grep with interactive TUI, fuzzy search, boolean queries, hexdumps and more
      - ugrep
      # jq - Command-line JSON processor
      - jq
      # go-yq - Portable command-line YAML processor
      - go-yq

      ## linter/beautifier
      # shfmt - Format shell programs
      - shfmt

      ### network-monitor
      - nload
      - bmon
      - iftop

      ## rpc
      # grpc - High performance, open source, general RPC framework that puts mobile and HTTP/2 first
      - grpc
      # gRPC protocol buffers cli
      - grpc-cli

      ## terminal
      # tmux - terminal multiplexer like screen
      - tmux
      # wezterm - GPU-accelerated cross-platform terminal emulator and multiplexer
      - wezterm
      # kitty - modern, hackable, featureful, OpenGL-based terminal emulator
      - kitty
      # vhs - A tool for recording terminal GIFs
      - vhs

      ### task-management
      # pueue - task management for sequential and parallel execution of long-running tasks
      - pueue

      ## trace
      # strace - diagnostic, debugging and instructional userspace tracer
      - strace
      # ltrace - tracks runtime library calls in dynamically linked program
      - ltrace
      # gdb - debugger for eg. reading coredumps
      - gdb
      # inotify-tools - a set of command-line programs (eg. inotifywait) providing a simple interface to inotify
      - inotify-tools

      ## updates
      # topgrade - Invoke the upgrade procedure of multiple package managers
      - topgrade

      ## viewer
      # zenity - Display graphical dialog boxes from shell scripts
      - zenity
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

      ## watch
      # urlwatch - Tool for monitoring webpages for updates
      - urlwatch

{% load_yaml as pkgs %}
      ### aur
      ## filter
      # yj - Convert YAML <=> TOML <=> JSON <=> HCL
      # - yj
      # ast-grep - A fast and polyglot tool for code structural search, lint, rewriting at large scale
      - ast-grep
      # marp - Markdown Presentation Ecosystem
      - marp-cli
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
      # gptfdisk - A text-mode partitioning tool that works on GUID Partition Table (GPT) disks
      - gptfdisk
      # multipath-tools - Multipath tools for Linux (including kpartx)
      - multipath-tools
      # jose - C-language implementation of Javascript Object Signing and Encryption
      - jose
      # mosquitto - Open Source MQTT Broker
      - mosquitto
      # nvchecker - New version checker for software releases plus optional packages
      - nvchecker
      # html, pypi, toml, git, json, alpm source, sort_version_key = vercmp, awesomeversion 
      - pyalpm
      - python-awesomeversion
      - python-aiohttp
      - python-lxml
      - python-jq
      - python-packaging
      - python-toml
      - git
      # vault - A tool for managing secrets
      - vault
      # step-cli - A zero trust swiss army knife for working with X509, OAuth, JWT, OATH OTP, etc.
      - step-cli
      # macchanger - small utility to change your NIC's MAC address
      - macchanger
      # kompose - Docker compose to Kubernetes transformation tool
      - kompose

{{ pacman_repo_key("flent", "DE6162B5616BA9C9CAAC03074A55C497F744F705",
    "7ea640aad9ea799bef1bc04a5db884d0be8700c59b2be5f898ef35b9d7294f8a", user=user) }}

{{ pacman_repo_key("selinux", "63191CE94183098689CAB8DB7EF137EC935B0EAF",
    "80862ce3e3de1cffa8f0a966c84a8f57296b1609f92d5696405bd2dcf038b819",
    owner="Jason Zaman <perfinion@gentoo.org>", user=user) }}

{% load_yaml as pkgs %}
      ## devop
      # mqttui - Subscribe to a MQTT Topic or publish quickly from the terminal
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
      # - vault-cli
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

