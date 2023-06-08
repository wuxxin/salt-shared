{% from 'aur/lib.sls' import aur_install, pacman_repo_key with context %}
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

