{% from 'arch/lib.sls' import aur_install, pacman_repo_key with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install, pipx_inject %}

3d-printing:
  pkg.installed:
    - pkgs:
      - cura-bin
      - cura-resources-materials

media-player:
  pkg.installed:
    - pkgs:
      # kodi -  software media player and entertainment hub for digital media
      - kodi

{% load_yaml as pkgs %}
      # wayland-pipewire-idle-inhibit - Inhibit wayland idle when computer is playing sound
      - wayland-pipewire-idle-inhibit
{% endload %}
{{ aur_install("manjaro-pipewire-aur", pkgs) }}

enable_wayland-pipewire-idle-inhibit:
  file.symlink:
    - name: {{ user_home+ '/.config/systemd/user/graphical-session.target.wants/wayland-pipewire-idle-inhibit.service' }}
    - target: /usr/lib/systemd/user/wayland-pipewire-idle-inhibit.service
    - makedirs: true
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - test: audio-pipewire-aur

# paper-aur
{% load_yaml as pkgs %}
      # paperless-ngx - supercharged paperless: scan, index and archive all your physical documents
      - paperless-ngx
{% endload %}
{{ aur_install("paper-aur", pkgs) }}

# audio-synthesizer-aur
{% load_yaml as pkgs %}
      - vcvrack
      - vcvrack-goodsheperd
      - vcvrack-freesurface
      - vcvrack-cvly
      - vcvrack-computerscare
      - vcvrack-collection-one
      - vcvrack-alikins
      - vcvrack-ahornberg
      - vcvrack-aaronstatic
{% endload %}
{{ aur_install("audio-synthesizer-aur", pkgs) }}

