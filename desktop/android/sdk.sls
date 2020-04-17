{% from "desktop/android/defaults.jinja" import settings as s with context %}

include:
  - java.jdk
  - desktop.android.tools

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

# sdk requisites
android-req:
  pkg.installed:
    - pkgs:
      - openjdk-8-jdk
      - gradle
      - maven
      - proguard-cli
      - lib32stdc++6
      - lib32z1
      - libgl1-mesa-dev
      - libc6:i386
      - libncurses5:i386
      - libstdc++6:i386
      - libbz2-1.0:i386
    - require:
      - sls: desktop.android.tools
      - sls: java.jdk

# Android SDK
sdk-manager:
  file.managed:
    - name: /usr/local/lib/sdk-tools-linux-{{ s.ANDROID_SDK_VERSION }}.zip
    - source: https://dl.google.com/android/repository/sdk-tools-linux-{{ s.ANDROID_SDK_VERSION }}.zip
    - source_hash: {{ s.ANDROID_SDK_HASH }}
  archive.extracted:
    - name: {{ s.ANDROID_HOME }}
    - source: /usr/local/lib/sdk-tools-linux-{{ s.ANDROID_SDK_VERSION }}.zip
    - archive_format: zip
    - if_missing: {{ s.ANDROID_HOME }}/tools/bin/sdkmanager

sdk-manager-perm:
  file.directory:
    - name: {{ s.ANDROID_HOME }}
    - user: {{ user }}
    - group: users
    - recurse:
        - user
        - group
    - watch:
      - archive: sdk-manager

{#
manager-install:
  cmd.run:
    - name: |
        {{ s.ANDROID_HOME }}/tools/bin/sdkmanager install \
        platform-tools \
        emulator \
        "platforms;android-{{ s.ANDROID_API }}" \
        "build-tools;{{ s.ANDROID_API_VER }}" \
        "system-images;android-{{ s.ANDROID_API }};default;{{ s.ANDROID_TARGET }}" \
        "system-images;android-{{ s.ANDROID_API }};google_apis_playstore;{{ s.ANDROID_TARGET }}" \
        "extras;google;google_play_services"
    - require:
      - pkg: android-req
      - archive: android-sdk
#}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% set marker = "# saltstack android development automatic config" %}
{% set start = marker+ " start" %}
{% set end = marker+ " end" %}

android-create-user-profile:
  file:
    - touch
    - name: {{ user_home }}/.profile

android-modify-user-profile:
  file.blockreplace: {# file.blockreplace does use "content" instead of "contents" #}
    - name: {{ user_home }}/.profile
    - marker_start: "{{ start }}"
    - marker_end: "{{ end }}"
    - content: |
        # set the environment variables
        # ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
        # ENV KOTLIN_HOME /opt/kotlinc
        # ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
        # WORKAROUND: for issue https://issuetracker.google.com/issues/37137213
        # ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

          export _JAVA_OPTIONS="-XX:+UnlockExperimentalVMOptions -XX:+IgnoreUnrecognizedVMOptions --add-modules java.se.ee"
        export PATH="${PATH}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin"
        export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"

        export ANDROIDAPI={{ grains['ANDROIDAPI'] }}
        export ANDROID_TARGET={{ grains['ANDROID_TARGET'] }}
        export PATH=${PATH}:${ANDROIDSDK}/tools:${ANDROIDSDK}/platform-tools
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: android-create-user-profile
 #     - cmd: android-sdk
 #     - cmd: android-ndk


# sdk license accept script
android-accept-license-user:
  file.managed:
    - source: salt://desktop/android/user/android-accept-license.sh
    - name: /usr/local/bin/android-accept-license.sh

accept-android-license-{{ user }}:
  cmd.run:
    - name: accept-android-license.sh
    - runas: {{ user }}
