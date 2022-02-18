keyring:
  pkg.installed:
    - pkgs:
      - gnome-keyring
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-keyring
      - keyringer
