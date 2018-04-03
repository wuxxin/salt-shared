gnupg:
  pkg.installed:
    - pkgs:
      - gnupg
      - gnupg-agent

/usr/local/bin/gpgutils.py:
  file.managed:
    - source: salt://gnupg/gpgutils.py
    - mode: "0755"
