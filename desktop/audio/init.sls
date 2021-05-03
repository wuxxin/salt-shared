audio-tools:
  pkg.installed:
    - pkgs:
      - sox
      - lame
      - pipewire

pulseaudio-tools:
  pkg.installed:
    - pkgs:
      - paprefs
      - pavucontrol
      - pavumeter
      - libsox-fmt-pulse

audio-editor:
  pkg.installed:
    - pkgs:
      - audacity
