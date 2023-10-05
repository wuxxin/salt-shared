include:
  - desktop.ubuntu.video.framework

video-editor:
  pkg.installed:
    - pkgs:
      - flowblade
    - require:
      - sls: desktop.ubuntu.video.framework

video-creation-conversion:
  pkg.installed:
    - pkgs:
      - mkvtoolnix-gui
      - handbrake
