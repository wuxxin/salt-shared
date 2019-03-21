include:
  - ubuntu
  - ubuntu.reporting.disabled
  - ubuntu.hibernate

{% load_yaml as defaults %}
bionic:
  xserver: xserver-xorg-hwe-18.04
generic:
  xserver: xserver-xorg
{% endload %}

{% set settings = salt['grains.filter_by'](defaults, 
  grain= 'lsb_distrib_codename', default= 'generic',
  merge= salt['pillar.get']('desktop:settings', {})) %}
    
install_desktop:
  pkg.installed:
    - pkgs:
      - {{ settings.xserver }}
      - gnome-core
      - gnome
      - vanilla-gnome-desktop
