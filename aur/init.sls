{% from 'aur/lib.sls' import aur_install with context %}

# enable aur, install group base-devel, build and debug tools

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

build_tools:
  pkg.installed:
    - pkgs:
      # git - fast distributed version control system
      - git
      # git-lfs - Git extension for versioning large files
      - git-lfs
      # gnupg - free implementation of the OpenPGP standard
      - gnupg
      # cmake - cross-platform open-source make system
      - cmake
      # dkms - dynamic kernel modules system
      - dkms
      # archlinux-contrib - Collection of contrib scripts used in Arch Linux
      - archlinux-contrib
    - require:
      - pkg: build_essentials

debug_tools:
  pkg.installed:
    - pkgs:
      # strace - diagnostic, debugging and instructional userspace tracer
      - strace
      # ltrace - tracks runtime library calls in dynamically linked program
      - ltrace
      # gdb - debugger for eg. reading coredumps
      - gdb
    - require:
      - pkg: build_essentials

{% load_yaml as pkgs %}
      # pikaur - aur helper, for building packages from AUR
      - pikaur
      # paru - Feature packed AUR helper
      - paru
      # asp - downloading repo pkgbuilds
      - asp
      # devtools - build in chroot
      - devtools
      # aurutils - helper tools for the arch user repository
      - aurutils
{% endload %}
{{ aur_install("build_tools-aur", pkgs, require="pkg: build_tools") }}


