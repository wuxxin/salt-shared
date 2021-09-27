{% if grains['os'] == 'Ubuntu' and grains['osmajorrelease'] >= 20 %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("pipewire_ppa", "pipewire-debian/pipewire-upstream",
  require_in = ["pkg: pipewire",]) }}

pipewire:
  pkg.installed:
    - pkgs:
      - pipewire
      - pipewire-locales
      - pipewire-audio-client-libraries
      - gstreamer1.0-pipewire
      - openaptx-utils
      - libcamera-tools
      - libspa-0.2-jack
      - libspa-0.2-bluetooth

{% else %}

pipewire:
  pkg.installed:
    - pkgs:
      - pipewire
      - gstreamer1.0-pipewire

{% endif %}

audio-tools:
  pkg.installed:
    - pkgs:
      - sox
      - libsox-fmt-pulse
      - libsox-fmt-ao
      - libsox-fmt-alsa
      - libsox-fmt-mp3
      - libasound2-plugins
      - libasound2-plugins-extra
