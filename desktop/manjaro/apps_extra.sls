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


/etc/modules-load.d/binder.conf:
  file.managed:
    - contents: |
      binder

{% load_yaml as pkgs %}
      # waydroid - container-based approach to boot a full Android system on a regular Linux system
      - waydroid
      # binder_linux-dkms-git - Binder kernel module for Waydroid
      - binder_linux-dkms-git
      - python-pyclip
      # waydroid-script-git - Python Script to add OpenGapps, Magisk, libhoudini translation library and libndk translation library
      - waydroid-script-git
      # waydroid-settings-git - GTK app written in Python to control Waydroid settings
      - waydroid-settings-git
      # either waydroid-image or waydroid-image-gapps
      # waydroid-image - LineageOS-based Android images for Waydroid
      # - waydroid-image
      # waydroid-image-gapps - LineageOS-based Android image with GAPPS for Waydroid
      - waydroid-image-gapps
{% endload %}
{{ aur_install("emulator-waydroid-aur", pkgs,
    require="file: /etc/modules-load.d/binder.conf" ) }}
