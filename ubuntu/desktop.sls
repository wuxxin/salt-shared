{% from "ubuntu/defaults.jinja" import settings with context %}

include:
  - ubuntu.snapd
  - ubuntu.telemetry
  - ubuntu.hibernate

install_desktop:
  pkg.installed:
    - pkgs:
      - {{ settings.desktop.xwayland }}
      - {{ settings.desktop.xserver }}
      - xserver-xephyr
      - xvfb
      - gnome
      - gnome-core
      - vanilla-gnome-desktop
    - require:
      - sls: ubuntu.snapd
      - sls: ubuntu.telemetry

cups-browsed:
  file.replace:
    - name: /etc/cups/cups-browsed.conf
    - pattern: '^BrowseRemoteProtocols.+'
    - repl: BrowseRemoteProtocols dnssd
    - append_if_not_found: true
    - require:
      - pkg: install_desktop
  cmd.run:
    - name: systemctl restart --no-block cups-browsed
    - onchanges:
      - file: cups-browsed
