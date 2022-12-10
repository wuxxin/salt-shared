include:
  - python

{%- if grains['os'] == 'Manjaro' %}
  {% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

android-tools:
  pkg.installed:
    - pkgs:
      # android-udev - Udev rules to connect Android devices to your linux box
      - android-udev
      # android-tools - Android platform tools
      - android-tools
      # gvfs-mtp - Virtual filesystem implementation for GIO (MTP backend; Android, media player)
      - gvfs-mtp
      # scrcpy - Display and control your Android device
      - scrcpy
      # heimdall - flash firmware (ROMs) onto Samsung Galaxy Devices
      - heimdall
{% load_yaml as pkgs %}
      #  android-bash-completion - Bash completion for android, adb, emulator, fastboot, and repo
      - android-bash-completion Bash completion for android, adb, emulator, fastboot, and repo
      # fdroidcl - F-Droid desktop client
      - fdroidcl
      # sndcpy-bin - Android audio forwarding (scrcpy, but for audio)
      - sndcpy-bin
      # gplaycli - search, install, update Android applications from the Google Play Store
      - gplaycli
      # apk-mitm - prepares Android APK files for HTTPS inspection
      - apk-mitm
      # adbfs-rootless-git - fuse filesystem over adb tool for android devices
      - adbfs-rootless-git
      # better-adb-sync-git - Synchronize files between a PC and an Android
      - better-adb-sync-git
      # adb-enhanced - Swiss-army knife for Android testing and development
      - python-adb-enhanced 
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
