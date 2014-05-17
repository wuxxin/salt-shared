include:
  - java.jdk

{% set ANDROIDSDK="/opt/android-sdk-linux" %}
{% set ANDROIDNDK="/opt/android-ndk-r9d" %}
{% set ANDROIDNDKVER="9d" %}
{% set ANDROIDAPI="22" %}
{% set filter= pillar['desktop.android.sdk.filter']|d('tools,platform-tools,build-tools-19,android-19,sysimg-19') %}

android-prereq:
  pkg.installed:
    - pkgs:
      - lib32stdc++6
      - lib32z1
      - expect
      - android-tools-adb
      - android-tools-adbd
      - android-tools-fastboot

android-sdk:
  archive.extracted:
    - name: /opt/
    - source: http://dl.google.com/android/android-sdk_r22.6.2-linux.tgz
    - source_hash: md5=ff1541418a44d894bedc5cef10622220
    - archive_format: tar
    - tar_options: z
    - if_missing: {{ ANDROIDSDK }}
{#
  file.directory:
    - name: {{ ANDROIDSDK }}
    - user: root
    - group: users
    - recurse:
        - user
        - group
    - require:
      - archive: android-sdk
#}
  cmd.run:
    - name: 'echo "Android-sdk: OK, refresh grains"'
    - require: 
      - archive: android-sdk

android-sdk-update:
  cmd.run:
    - name: |
        expect -c '
        set timeout -1;
        spawn {{ ANDROIDSDK }}/tools/android update sdk --no-ui --filter {{ filter }};
        expect {
          "accept the license" {exp_send "y\r"; exp_continue}
          eof
        }
        '
    - cwd: {{ ANDROIDSDK }}
    - require:
      - file: android-sdk
      - pkg: default-jdk
      - pkg: android-prereq
    - require_in:
      - cmd: android-sdk

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


android-ndk:
  archive.extracted:
    - name: /opt/
    - source: http://dl.google.com/android/ndk/android-ndk-r9d-linux-x86_64.tar.bz2
    - source_hash: md5=c7c775ab3342965408d20fd18e71aa45
    - archive_format: tar
    - tar_options: j
    - if_missing: {{ ANDROIDNDK }}
{#
  file.directory:
    - name: {{ ANDROIDNDK }}
    - user: root
    - group: users
    - recurse:
        - user
        - group
    - require:
      - pkg: android-prereq
    - watch:
      - archive: android-ndk
#}
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
