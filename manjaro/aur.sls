# enable aur , install group base-devel, build and debug tools
enable_aur:
  file.replace:
    - name: /etc/pamac.conf
    - pattern: ^#?EnableAUR.*
    - repl: EnableAUR
    - append_if_not_found: true

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
      # pikaur - aur helper, for building packages from AUR
      - pikaur

debug_tools:
  pkg.installed:
    - pkgs:
      # strace - diagnostic, debugging and instructional userspace tracer
      - strace
      # ltrace - tracks runtime library calls in dynamically linked program
      - ltrace
      # gdb - debugger for eg. reading coredumps
      - gdb
