{% if grains['os'] == 'Ubuntu' %}

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
include:
  - flatpak

add-flathub-repository:
  cmd.run:
    - runas: {{ user }}
    - name: flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

install-flatpak-torbrowser-launcher:
  cmd.run:
    - runas: {{ user }}
    - name: flatpak install flathub com.github.micahflee.torbrowser-launcher

{% else %}

torbrowser-launcher:
  pkg:
    - installed

{% endif %}
