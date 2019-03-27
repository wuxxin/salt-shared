gconf-editor:
  pkg:
    - installed

{#
Differences to ubuntu-desktop-minimal & ubuntu-desktop

xcursor-themes
dmz-cursor-theme
gsettings-ubuntu-schemas yaru-theme-gnome-shell yaru-theme-gtk yaru-theme-icon yaru-theme-sound
libreoffice-style-breeze
#}

fonts:
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

gtk3-themes:
  pkg.installed:
    - pkgs:
      - gtk3-engines-unico

gnome-shell-extensions:
  pkg.installed:
    - pkgs:
      - gnome-shell-extension-mediaplayer
      - gnome-shell-extension-appindicator
      - gnome-shell-extension-top-icons-plus
      - gnome-shell-extension-hard-disk-led
      - gnome-shell-extension-pixelsaver
      - gnome-shell-extension-system-monitor
      - gnome-shell-extension-weather
