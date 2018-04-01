remove_zentyal_desktop:
  pkg.purged:
    - pkgs:
      - evince
      - firefox
      - gksu
      - gtk2-engines
      - libnss3-tools
      - lxde
      - lxdm
      - xdg-user-dirs
      - xorg
      - xscreensaver
      - zenbuntu-desktop

remove_unused_config:
  cmd.run:
    - name: dpkg -l | grep '^rc' | awk '{print $2}' | xargs dpkg --purge
    - require:
      - remove_zentyal_desktop
