include:
  - ubuntu.desktop

additional-desktop-packages:
  pkg.installed:
    - pkgs:
      - gconf-editor
      - xcursor-themes
      - dmz-cursor-theme 
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
      - fonts-lmodern
      - fonts-larabie-deco
      - fonts-larabie-straight

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

nautilus-plugins:
  pkg.installed:
    - pkgs:
      - seahorse-nautilus
      - nautilus-image-converter
