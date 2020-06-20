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
      - zsnapd
      - zsnapd-rcmd

{# keep snapd from installing again, eg. by installing chromium #}
/etc/apt/preferences.d/snapd-preference:
  file.managed:
    - contents: |
        Package: snapd
        Pin: release o=Ubuntu
        Pin-Priority: -1
