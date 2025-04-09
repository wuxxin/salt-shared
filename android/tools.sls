{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'arch/lib.sls' import aur_install with context %}
{% from 'python/lib.sls' import pipx_install %}

include:
  - code.python

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
      # mitmproxy - SSL-capable man-in-the-middle HTTP proxy
      - mitmproxy
{% load_yaml as pkgs %}
      #  android-bash-completion - Bash completion for android, adb, emulator, fastboot, and repo
      # - android-bash-completion
      # fdroidcl - F-Droid desktop client
      - fdroidcl
      # sndcpy-bin - Android audio forwarding (scrcpy, but for audio)
      # - sndcpy-bin
      # gplaycli - search, install, update Android applications from the Google Play Store
      # - gplaycli
      # android-apktool - tool for reengineering Android apk files
      - android-apktool
      # FIXME-BUILD WORKS AS USER frida - Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers
      - python-frida
      # apk-mitm - prepares Android APK files for HTTPS inspection
      - apk-mitm
      # adbfs-rootless-git - fuse filesystem over adb tool for android devices
      - adbfs-rootless-git
      # better-adb-sync-git - Synchronize files between a PC and an Android
      - better-adb-sync-git
      # adb-enhanced - Swiss-army knife for Android testing and development
      # - python-adb-enhanced
      # - gnirehtet
{% endload %}
{{ aur_install('android-tools-aur', pkgs, require='pkg: android-tools') }}

# python-frida-tools - CLI tools for Frida.
{{ pipx_install('frida-tools', user=user) }}

android-local-tools:
  file.directory:
    - name: {{ user_home }}/.local/bin
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true

{{ user_home }}/.local/bin/launch-android.sh:
  file.managed:
    - user: {{ user }}
    - group: {{ user }}
    - mode: "775"
    - source: salt://android/launch-android.sh

{{ user_home }}/.local/bin/imei-calc.py:
  file.managed:
    - user: {{ user }}
    - group: {{ user }}
    - mode: "775"
    - source: salt://android/imei-calc.py
