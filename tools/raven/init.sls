{% from "python/lib.sls" import pip2_install, pip3_install %}

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

# python2 packages needed for saltstack raven (_returners/raven_return.py)
python2-saltstack-raven-packages:
  pkg.installed:
    - pkgs:
      - python-requests

# install both python raven versions
{{ pip3_install('raven') }}
{{ pip2_install('raven') }}

/usr/local/bin/ravencat.py:
  file.managed:
    - source: salt://tools/raven/ravencat.py
    - mode: "0755"
