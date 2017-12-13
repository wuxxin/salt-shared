include:
  - ubuntu.desktop
  - .user

restricted-extras:
  pkg.installed:
    - pkgs:
      - ttf-mscorefonts-installer

gconf-editor:
  pkg:
    - installed

compiz-tweaks:
  pkg.installed:
    - pkgs:
      - compizconfig-settings-manager

themes-extra:
  pkg.installed:
    - pkgs:
      - gnome-themes-ubuntu
      - light-themes
      - elementary-icon-theme
      - gtk-theme-config
      - gtk-theme-switch
      - gnome-tweak-tool
