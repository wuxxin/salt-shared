include:
  - ubuntu.desktop

additional-desktop-packages:
  pkg.installed:
    - pkgs:
      - gconf-editor
      - gsettings-ubuntu-schemas
      - gnome-remote-desktop
      - indicator-application

remove-unwanted-desktop-packages:
  pkg.removed:
    - pkgs:
      - gnome-games
  module.run:
    - name: pkg.autoremove
    - onchanges:
      - pkg: remove-unwanted-desktop-packages

desktop-fonts:
  pkg.installed:
    - pkgs:
      - fonts-dejavu
      - fonts-ubuntu
      - fonts-liberation2
      - fonts-droid-fallback
      - fonts-noto-core
      - fonts-noto-mono
      - fonts-noto-ui-core
      - fonts-lmodern
      - fonts-larabie-deco
      - fonts-larabie-straight

cursor-themes:
  pkg.installed:
    - pkgs:
      - xcursor-themes
      - dmz-cursor-theme

icon-themes:
  pkg.installed:
    - pkgs:
      - adwaita-icon-theme
      - elementary-icon-theme

{%- if grains['osmajorrelease']|int >= 18 and grains['osrelease'] != '18.04' %}
yaru-theme:
  pkg.installed:
    - pkgs:
      - yaru-theme-gnome-shell
      - yaru-theme-gtk
      - yaru-theme-icon
      - yaru-theme-sound
{%- endif %}

eog-plugins:
  pkg.installed:
    - pkgs:
      - eog
      - eog-plugins

nautilus-plugins:
  pkg.installed:
    - pkgs:
      - seahorse-nautilus
      - nautilus-image-converter
