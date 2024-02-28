include:
  - python

{%- if grains['os'] == 'Manjaro' %}
  {% from 'arch/lib.sls' import aur_install with context %}

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
      - android-bash-completion
      # fdroidcl - F-Droid desktop client
      - fdroidcl
      # sndcpy-bin - Android audio forwarding (scrcpy, but for audio)
      # - sndcpy-bin
      # gplaycli - search, install, update Android applications from the Google Play Store
      - gplaycli
      # android-apktool - tool for reengineering Android apk files
      - android-apktool
      # frida - Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers
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


{%- elif grains['os'] == 'Ubuntu' %}

android-tools:
  pkg.installed:
    - pkgs:
      - adb
      - fastboot
      - heimdall-flash

{% endif %}
