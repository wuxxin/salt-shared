include:
  - desktop.video.base

video-editor:
  pkg.installed:
    - pkgs:
      - flowblade
    - require:
      - sls: desktop.video.base
