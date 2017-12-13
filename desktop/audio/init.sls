include:
  - desktop.audio.ppa
  
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
      {# from ppa up to zesty #}
      - pulseaudio-dlna
    - require:
      - sls: desktop.audio.ppa

audio-player:
  pkg.installed:
    - pkgs:
      - banshee
