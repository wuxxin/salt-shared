{% from 'desktop/user/lib.sls' import user, user_info, user_home, add_to_groups with context %}
{% from 'arch/lib.sls' import aur_install with context %}
{% from 'code/python/lib.sls' import pipx_install %}

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
      # python-polib - lost dependency for pixelflasher
      - python-polib
{% load_yaml as pkgs %}
      # fdroidcl - F-Droid desktop client
      - fdroidcl
      # qtscrcpy - Android real-time screencast control tool
      - qtscrcpy
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
      # pixelflasher - Pixel phone flashing GUI utility with features
      - pixelflasher
      # android-bash-completion - Bash completion for android, adb, emulator, fastboot, and repo
      # - android-bash-completion
      # adb-enhanced - Swiss-army knife for Android testing and development
      # - python-adb-enhanced
      # - gnirehtet
      # sndcpy-bin - Android audio forwarding (scrcpy, but for audio)
      # - sndcpy-bin
      # gplaycli - search, install, update Android applications from the Google Play Store
      # - gplaycli{% endload %}
{{ aur_install('android-tools-aur', pkgs, require='pkg: android-tools') }}

# add user to adbusers (udev management)
{{ add_to_groups(user, ['adbusers']) }}


# python-frida-tools - CLI tools for Frida.
{{ pipx_install('frida-tools', user=user) }}

# tap device script needs root, put it in /usr/local/sbin as root, so only root can modify it.
#   should be safe to use as complete command line with parameter in sudoers.d/ without password,
#   eg.: sudo /usr/local/sbin/tap-device.sh up lan-bridge tap-pixel8
android-tap-device-script:
  file.managed:
    - name: /usr/local/sbin/tap-device.sh
    - source: salt://android/tap-device.sh
    - mode: "0755"

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
