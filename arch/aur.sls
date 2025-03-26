{% from 'arch/lib.sls' import aur_install with context %}

# enable aur, install group base-devel, build and distribution tools

{% if grains['os'] == 'Manjaro' %}

enable_aur:
  file.replace:
    - name: /etc/pamac.conf
    - pattern: ^#?EnableAUR.*
    - repl: EnableAUR
    - append_if_not_found: true
    - require_in:
      - pkg: build_tools

{% endif %}

build_essentials:
  pkg.group_installed:
    - name: base-devel

{% for value in ['permit nopass keepenv root', 'permit :wheel'] %}
"doas__{{ value }}":
  file.replace:
    - name: /etc/doas.conf
    - pattern: ^{{ value }}
    - repl: {{ value }}
    - append_if_not_found: true
    - require_in:
      - pkg: build_tools
{% endfor %}

build_tools:
  pkg.installed:
    - pkgs:
      # opendoas - Run commands as super user or another user
      - opendoas
      # git - fast distributed version control system
      - git
      # git-lfs - Git extension for versioning large files
      - git-lfs
      # gnupg - free implementation of the OpenPGP standard
      - gnupg
      # cmake - cross-platform open-source make system
      - cmake
      # ninja - Small build system with a focus on speed
      - ninja
      # dkms - dynamic kernel modules system
      - dkms
      # archlinux-contrib - Collection of contrib scripts used in Arch Linux
      - archlinux-contrib
      # rebuild-detector - Detects which packages need to be rebuilt
      - rebuild-detector
      # pacman-contrib - Contributed scripts and tools for pacman systems
      - pacman-contrib
    - require:
      - pkg: build_essentials

{% load_yaml as pkgs %}
      # pikaur - aur helper, for building packages from AUR
      - pikaur
      # paru - Feature packed AUR helper
      - paru
      # yay - Yet another yogurt. Pacman wrapper and AUR helper written in go
      - yay
      # asp - downloading repo pkgbuilds
      - asp
      # downgrade - Bash script for downgrading one or more packages to a version in your cache or the A.L.A.
      - downgrade
      # aurutils - helper tools for the arch user repository
      - aurutils
      # archosaur - a PKGBUILD management framework for the Arch User Repository
      - archosaur
{% endload %}
{{ aur_install("build_tools-aur", pkgs, require="pkg: build_tools") }}

{% if grains['os'] == 'Arch' %}
build_tools_arch:
  pkg.installed:
    - pkgs:
      # devtools - Tools for Arch Linux package maintainers
      - devtools
    - require:
      - pkg: build_essentials
{% endif %}

{% if grains['os'] == 'Manjaro' %}
build_tools_manjaro:
  pkg.installed:
    - pkgs:
      # Development tools for Manjaro Linux (base tools)
      - manjaro-tools-base-git
      # Development tools for Manjaro Linux (ISO tools)
      - manjaro-tools-iso-git
      # Development tools for Manjaro Linux (packaging tools, equal to arch devtools)
      - manjaro-tools-pkg-git
      # Development tools for Manjaro Linux (yaml tools)
      - manjaro-tools-yaml-git
    - require:
      - pkg: build_essentials
{% endif %}
