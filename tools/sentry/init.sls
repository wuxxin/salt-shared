{% from "python/lib.sls" import pip_install %}

include:
  - python

# python3 packages needed for sentrycat
python3-sentrycat-packages:
  pkg.installed:
    - pkgs:
      - python3-requests
      - python3-chardet
    - require:
      - sls: python

{{ pip_install('sentry-sdk>=0.7.3', require= 'pkg: python3-sentrycat-packages') }}

/usr/local/bin/sentrycat.py:
  file.managed:
    - source: salt://tools/sentry/sentrycat.py
    - mode: "0755"
