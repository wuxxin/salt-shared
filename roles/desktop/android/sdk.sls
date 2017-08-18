include:
  - .tools
  - java.jdk
  - .user

{% from 'roles/desktop/user/lib.sls' import user, user_info, user_home with context %}

{% set ANDROIDSDK="/opt/android-sdk-linux" %}
{% set ANDROIDNDK="/opt/android-ndk-r10" %}

{% set ANDROIDAPI="23" %}
{% set ANDROIDNDKVER="10" %}
{% set ANDROID_TARGET="android-19" %}

{% set SDK_URL= "http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz"  %}
{% set SDK_HASH= "md5=94a8c62086a7398cc0e73e1c8e65f71e" %}

{% set NDK_URL= "http://dl.google.com/android/ndk/android-ndk64-r10-linux-x86_64.tar.bz2" %}
{% set NDK_HASH= "md5=737290195583268b7fbff4aa56465ab6" %}

{% set sdk_all_filter= pillar['desktop.android.sdk.all_filter']|d(
'sys-img-armeabi-v7a-'+ ANDROID_TARGET+
'sys-img-x86-'+ ANDROID_TARGET) %}

{% set sdk_filter= pillar['desktop.android.sdk.filter']|d(
'platform-tools,build-tools-20.0.0,extra-android-support,'+ ANDROID_TARGET+
'extra-google-google_play_services') %}
# 'addon-google_apis_x86-google-19,addon-google_apis-google-19'

# lists all packages in human readable form
# android list sdk --no-ui --all --extended | grep -E '^id:' | awk -F '"' '{$1=""; print $2}'

# http://dl.google.com/android/android-sdk_r22.6.2-linux.tgz
# md5=ff1541418a44d894bedc5cef10622220
# http://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2
# md5=c7c775ab3342965408d20fd18e71aa45

android-prereq:
  pkg.installed:
    - pkgs:
      - lib32stdc++6
      - lib32z1
      - expect
      - libgl1-mesa-dev
      # libgl1-mesa-dev is used for libGL.so in android emulator -gpu on
    - require:
      - pkg: tools

android-sdk:
  archive.extracted:
    - name: /opt/
    - source: {{ SDK_URL }}
    - source_hash: {{ SDK_HASH }}
    - archive_format: tar
    - tar_options: z
    - if_missing: {{ ANDROIDSDK }}
  file.directory:
    - name: {{ ANDROIDSDK }}
    - user: {{ user }}
    - group: users
    - recurse:
        - user
        - group
    - watch:
      - archive: android-sdk
  cmd.run:
    - name: 'echo "Android-sdk: OK, refresh grains"'
    - require:
      - archive: android-sdk

{% for a,f in (('--all', sdk_all_filter),('', sdk_filter)) %}

android-sdk-update{{ a }}:
  cmd.run:
    - name: |
        expect -c '
        set timeout -1;
        spawn {{ ANDROIDSDK }}/tools/android update sdk --no-ui {{ a }} --filter {{ f }};
        expect {
          "accept the license" {exp_send "y\r"; exp_continue}
          eof
        }
        '
    - cwd: {{ ANDROIDSDK }}
    - runas: {{ user }}
    - require:
      - file: android-sdk
      - pkg: default-jdk
      - pkg: android-prereq
    - require_in:
      - cmd: android-sdk

{% endfor %}

android-grain-ANDROIDSDK:
  module.run:
    - name: grains.setval
      key: ANDROIDSDK
      val: {{ ANDROIDSDK }}
    - require_in:
      - cmd: android-sdk

android-grain-ANDROIDAPI:
  module.run:
    - name: grains.setval
      key: ANDROIDAPI
      val: {{ ANDROIDAPI }}
    - require_in:
      - cmd: android-sdk

android-grain-ANDROID_TARGET:
  module.run:
    - name: grains.setval
      key: ANDROID_TARGET
      val: {{ ANDROID_TARGET }}
    - require_in:
      - cmd: android-sdk


android-ndk:
  archive.extracted:
    - name: /opt/
    - source: {{ NDK_URL }}
    - source_hash: {{ NDK_HASH }}
    - archive_format: tar
    - tar_options: j
    - if_missing: {{ ANDROIDNDK }}
  file.directory:
    - name: {{ ANDROIDNDK }}
    - user: {{ user }}
    - group: users
    - recurse:
        - user
        - group
    - require:
      - pkg: android-prereq
    - watch:
      - archive: android-ndk
  cmd.run:
    - name: 'echo "Android-ndk: OK"'
    - require:
      - archive: android-ndk

android-grain-ANDROIDNDK:
  module.run:
    - name: grains.setval
      key: ANDROIDNDK
      val: {{ ANDROIDNDK }}
    - require_in:
      - cmd: android-ndk

android-grain-ANDROIDNDKVER:
  module.run:
    - name: grains.setval
      key: ANDROIDNDKVER
      val: {{ ANDROIDNDKVER }}
    - require_in:
      - cmd: android-ndk
