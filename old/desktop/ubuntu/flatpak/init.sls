{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("flatpak_ppa", "alexlarsson/flatpak",
  require_in = ["pkg: flatpak", "pkg: gnome-software-plugin-flatpak"]) }}
{% endif %}

flatpak:
  pkg:
    - installed

gnome-software-plugin-flatpak:
  pkg:
    - installed

{#
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.micahflee.torbrowser-launcher
#}
