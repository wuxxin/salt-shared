include:
  - roles.desktop.android.sdk

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% set marker = "# saltstack android development automatic config" %}
{% set start = marker+ " start" %}
{% set end = marker+ " end" %}

android-create-user-profile:
  file:
    - touch
    - name: {{ user_home }}/.profile

android-modify-user-profile:
  file.blockreplace:
    - name: {{ user_home }}/.profile
    - marker_start: "{{ start }}"
    - marker_end: "{{ end }}"
    - contents: |
        export ANDROIDSDK={{ grains['ANDROIDSDK'] }}
        export ANDROIDAPI={{ grains['ANDROIDAPI'] }}
        export ANDROIDNDK={{ grains['ANDROIDNDK'] }}
        export ANDROIDNDKVER={{ grains['ANDROIDNDKVER'] }}
        export ANDROID_TARGET={{ grains['ANDROID_TARGET'] }}
        export PATH=${PATH}:${ANDROIDSDK}/tools:${ANDROIDSDK}/platform-tools
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: android-create-user-profile
 #     - cmd: android-sdk
 #     - cmd: android-ndk


android-create-avd:
  cmd.run:
    - name: 'echo -en "no\n" | android create avd --force --snapshot -n test -t android-19'

#android-run-avd:
#  cmd.run:
#    - name: 'emulator -gpu on -memory 1024 @test'
