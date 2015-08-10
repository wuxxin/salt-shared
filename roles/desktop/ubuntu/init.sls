include:
  - ubuntu.desktop
  - .restricted
  - .user

gconf-editor:
  pkg:
    - installed
    
themes-extra:
  pkg.installed:
    - pkgs:
      - gnome-themes-extras
      - gnome-themes-ubuntu
      - light-themes
      - elementary-icon-theme
      - gtk-theme-config
      - gtk-theme-switch
      - themecolorizer
      - gnome-tweak-tool
