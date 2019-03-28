include:
  - python

android-tools:
  pkg.installed:
    - pkgs:
{%- if grains['osmajorrelease']|int < 18 %}
      - android-tools-adb
      - android-tools-fastboot
{%- else %}
      - adb
      - fastboot
{%- endif %}
      - android-tools-adbd
      - aapt

python-adb-req:
  pkg.installed:
    - pkgs:
      - python3-pycryptodome
      - python3-libusb1
      - python3-progressbar
      {# either python3-pycryptodome or python3-rsa #}

{% from 'python/lib.sls' import pip3_install %}
{{ pip3_install('adb', require='pkg: python-adb-req') }}

heimdall:
  pkg.installed:
    - pkgs:
      - heimdall-flash
      - heimdall-flash-frontend
