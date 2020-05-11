include:
  - ubuntu
  - ubuntu.reporting.disabled
  - ubuntu.hibernate

{% load_yaml as defaults %}
bionic:
  xserver: xserver-xorg-hwe-18.04
  xwayland: xwayland-hwe-18.04
generic:
  xserver: xserver-xorg
  xwayland: xwayland
{% endload %}

{% set settings = salt['grains.filter_by'](defaults,
  grain= 'lsb_distrib_codename', default= 'generic',
  merge= salt['pillar.get']('desktop:settings', {})) %}

install_desktop:
  pkg.installed:
    - pkgs:
      - {{ settings.xwayland }}
      - {{ settings.xserver }}
      - gnome
      - gnome-core
      - vanilla-gnome-desktop

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
