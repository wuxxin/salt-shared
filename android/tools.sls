include:
  - python

{%- if grains['os'] == 'Manjaro' %}
  {% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

android-tools:
  pkg.installed:
    - pkgs:
      - android-udev
      - android-tools
      - gvfs-mtp
      - scrcpy
      - heimdall
{% load_yaml as pkgs %}
      - sndcpy-bin
      - gplaycli
      - apk-mitm
      # - gnirehtet
{% endload %}
{{ pamac_install('android-tools-aur', pkgs, require='pkg: android-tools') }}


{%- elif grains['os'] == 'Ubuntu' %}

android-tools:
  pkg.installed:
    - pkgs:
      - adb
      - fastboot
      - aapt
      - heimdall-flash
      - heimdall-flash-frontend

{% from 'python/lib.sls' import pip_install %}
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

{% endif %}
