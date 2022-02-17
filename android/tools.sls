include:
  - python

{% from 'python/lib.sls' import pip_install %}

android-tools:
  pkg.installed:
    - pkgs:
{%- if grains['os'] == 'Ubuntu' and grains['osmajorrelease']|int < 18 %}
      - android-tools-adb
      - android-tools-fastboot
{%- else %}
      - adb
      - fastboot
{%- endif %}
      - aapt

python-adb-req:
  pkg.installed:
    - pkgs:
      - python3-pycryptodome
      - python3-rsa
      - python3-libusb1
      - python3-progressbar
      {# either python3-pycryptodome or python3-rsa #}
{{ pip_install('adb', require='pkg: python-adb-req') }}

python-gplaycli-req:
  pkg.installed:
    - pkgs:
      - python3-pyaxmlparser
      - python3-gpapi
{{ pip_install('gplaycli', require='pkg: python-gplaycli-req') }}

heimdall:
  pkg.installed:
    - pkgs:
      - heimdall-flash
      - heimdall-flash-frontend
