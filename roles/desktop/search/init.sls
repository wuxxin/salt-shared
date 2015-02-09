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
      - python-chm
      - python-mutagen
      - unrtf
      - untex
    - require:
      - pkgrepo: recoll_ppa
