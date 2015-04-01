include:
  - .init


recoll_server:
  user.present:
    - name: recoll
  group.present:
    - name: recoll
  git.latest:
    source: https://github.com/koniu/recoll-webui.git
    target: /home/recoll/recoll-webui

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
