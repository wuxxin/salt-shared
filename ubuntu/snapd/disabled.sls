snapd_masked:
  service.masked:
    - name: snapd

snapd:
  service.dead:
    - enable: false
  pkg.purged:
    - pkgs:
      - snapd 
      - gnome-software-plugin-snap
      - ubuntu-core-launcher
