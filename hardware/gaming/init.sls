{% from 'aur/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

gaming-mice-and-keyboard:
  pkg.installed:
    - pkgs:
      # libratbag - A DBus daemon to configure gaming mice
      - libratbag
      # piper - GTK application to configure gaming mice
      - piper

{{ pacman_repo_key("razer", "BD04DA24C971B8D587B2B8D7FAF69CF6CD2D02CD",
    "54de1ec58446c875e533f9a577bf7e98325863ec11cf585f6d3521614406fb92", user=user) }}

openrazer:
  pkg.installed:
    - pkgs:
      # openrazer-daemon - DBus daemon that abstracts access to the kernel driver
      - openrazer-daemon
      # openrazer-driver-dkms - OpenRazer kernel modules sources
      - openrazer-driver-dkms
{% load_yaml as pkgs %}
      # polychromatic - RGB lighting management front-end application for OpenRazer
      - polychromatic
      # razergenie - Configure and control your Razer devices
      - razergenie
{% endload %}

{{ aur_install("openrazer-aur", pkgs,
    require=["test: trusted-repo-razer", "pkg: openrazer"]) }}
