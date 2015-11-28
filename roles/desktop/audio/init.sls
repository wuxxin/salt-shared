include:
  - .ppa
  
audio-packages:
  pkg.installed:
    - pkgs:
      - paman
      - paprefs
      - pavucontrol
      - padevchooser
      - pavumeter
      - sox
      - libsox-fmt-pulse
      - lame

audio-player:
  pkg.installed:
    - pkgs:
      - banshee
