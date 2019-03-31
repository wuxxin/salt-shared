{% from "python/lib.sls" import pip3_install %}

include:
  - python

# python3 packages needed for ravencat
python3-ravencat-req:
  pkg.installed:
    - pkgs:
      - python3-requests
      - python3-chardet
    - require:
      - sls: python

{{ pip3_install('raven', require= 'pkg: python3-ravencat-req') }}

/usr/local/bin/ravencat.py:
  file.managed:
    - source: salt://tools/raven/ravencat.py
    - mode: "0755"
