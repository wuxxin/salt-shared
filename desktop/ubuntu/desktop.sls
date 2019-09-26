additional-desktop-packages:
  pkg.installed:
    - pkgs:
      - gconf-editor
      - xcursor-themes
      - dmz-cursor-theme 
      - gsettings-ubuntu-schemas
      - gnome-remote-desktop
      - indicator-application
{#
      - alacarte
#}

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
{% if grains['osrelease_info'][0]|int <= 17 and
    grains['osrelease'] != '17.10' %}
      - fonts-liberation
{% else %}
      - fonts-liberation2
{% endif %}

{% if grains['lsb_distrib_codename'] == 'trusty' %}
      - fonts-droid
{% else %}
      - fonts-droid-fallback
{% endif %}
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

{# 
gnome-shell-extensions:
  pkg.installed:
    - pkgs:
      - gnome-shell-extension-appindicator
      - gnome-shell-extension-hard-disk-led
      - gnome-shell-extension-pixelsaver
      - gnome-shell-extension-system-monitor
      - gnome-shell-extension-weather
#}
