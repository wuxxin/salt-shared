{% from "desktop/android/defaults.jinja" import settings as s with context %}

include:
  - java.jdk
  - .tools
  - .user

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

# Gradle
gradle:
  file.managed:
    - source: https://services.gradle.org/distributions/gradle-{{ s.GRADLE_VERSION }}-bin.zip
    - target: /var/local/lib/gradle-{{ s.GRADLE_VERSION }}-bin.zip
  archive.extracted:
    - name: /var/local/lib/gradle-{{ s.GRADLE_VERSION }}-bin.zip
    - target: /opt/

# Kotlin compiler
kotlin-compiler:
  file.managed:
    - source: https://github.com/JetBrains/kotlin/releases/download/v{{ s.KOTLIN_VERSION }}/kotlin-compiler-{{ s.KOTLIN_VERSION }}.zip
    - target: /var/local/lib/kotlin-compiler-{{ s.KOTLIN_VERSION }}.zip
  archive.extract:
    - name: /var/local/lib/kotlin-compiler-{{ s.KOTLIN_VERSION }}.zip
    - target: /opt/

android-prereq:
  pkg.installed:
    - pkgs:
      - lib32stdc++6
      - lib32z1
      - libgl1-mesa-dev
      - libc6:i386
      - libncurses5:i386
      - libstdc++6:i386
      - libbz2-1.0:i386
    - require:
      - pkg: .tools

# Android SDK
android-sdk:
  file.managed:
    - source: https://dl.google.com/android/repository/sdk-tools-linux-{{ s.ANDROID_SDK_VERSION }}.zip
    - target: /var/local/lib/sdk-tools-linux-{{ s.ANDROID_SDK_VERSION }}.zip
  archive.extracted:
    - name: {{ S.ANDROID_HOME }}/tools
    - source: /var/local/lib/sdk-tools-linux-{{ s.ANDROID_SDK_VERSION }}.zip
    - source_hash: {{ s.ANDROID_SDK_HASH }}
    - archive_format: zip
    - if_missing: {{ S.ANDROID_HOME }}/tools/bin/sdkmanager
  file.directory:
    - name: {{ ANDROIDSDK }}
    - user: {{ user }}
    - group: users
    - recurse:
        - user
        - group
    - watch:
      - archive: android-sdk

manager-install:
  cmd.run:
    - name: {{ s.ANDROID_HOME }}/tools/bin/sdkmanager platform-tools  "build-tools;28.0.3" "system-images;android-28;default;x86_64" "platforms;android-28" emulator "extras;google;google_play_services" "system-images;android-28;google_apis_playstore;x86_64"
