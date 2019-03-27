include:
  - .ppa

recoll:
  pkg.installed:
    - pkgs:
      - recoll
      - antiword
      - catdoc
      - ghostscript
      - libimage-exiftool-perl
      - poppler-utils
      - pstotext
      - python3-chm
      - python3-mutagen
      - unrtf
      - untex
    - require:
      - pkgrepo: recoll_ppa
