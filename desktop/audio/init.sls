audio-packages:
  pkg.installed:
    - pkgs:
      - paprefs
      - pavucontrol
      - pavumeter
      - sox
      - libsox-fmt-pulse
      - lame
      - pulseaudio-dlna  {# available since bionic #}

audio-editor:
  pkg.installed:
    - pkgs:
      - audacity
