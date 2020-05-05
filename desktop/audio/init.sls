audio-packages:
  pkg.installed:
    - pkgs:
      - paprefs
      - pavucontrol
      - pavumeter
      - sox
      - libsox-fmt-pulse
      - lame
      {# pulseaudio-dlna  only available in bionic #}

audio-editor:
  pkg.installed:
    - pkgs:
      - audacity
