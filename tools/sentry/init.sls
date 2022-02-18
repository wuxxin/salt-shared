{% from "python/lib.sls" import pip_install %}

include:
  - python

# python packages needed for sentrycat
python-sentrycat-packages:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-requests
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-chardet
    - require:
      - sls: python

{{ pip_install('sentry-sdk>=0.7.3', require= 'pkg: python-sentrycat-packages') }}

/usr/local/bin/sentrycat.py:
  file.managed:
    - source: salt://tools/sentry/sentrycat.py
    - mode: "0755"
