gnupg:
  pkg.installed:
    - pkgs:
      - gnupg

/usr/local/bin/gpgutils.py:
  file.managed:
    - source: salt://tools/gnupg/gpgutils.py
    - mode: "0755"
