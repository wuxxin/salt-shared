{% from "python/lib.sls" import pip3_install %}

include:
  - python

# python3 packages needed for sentrycat
python3-sentrycat-req:
  pkg.installed:
    - pkgs:
      - python3-requests
      - python3-chardet
    - require:
      - sls: python

{{ pip3_install('sentry-sdk', require= 'pkg: python3-sentrycat-req') }}

/usr/local/bin/sentrycat.py:
  file.managed:
    - source: salt://tools/sentry/sentrycat.py
    - mode: "0755"
