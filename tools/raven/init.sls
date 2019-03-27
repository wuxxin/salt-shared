{% from "python/lib.sls" import pip3_install %}

include:
  - python

# python3 packages needed for ravencat
python3-ravencat-packages:
  pkg.installed:
    - pkgs:
      - python3-requests
      - python3-chardet
    - require:
      - sls: python

# install raven
{{ pip3_install('raven') }}

/usr/local/bin/ravencat.py:
  file.managed:
    - source: salt://tools/raven/ravencat.py
    - mode: "0755"
