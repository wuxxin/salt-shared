include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("flatpak_ppa", "alexlarsson/flatpak",
  require_in = ["pkg: flatpak", "pkg: gnome-software-plugin-flatpak"]) }}

flatpak:
  pkg:
    - installed

gnome-software-plugin-flatpak:
  pkg:
    - installed
