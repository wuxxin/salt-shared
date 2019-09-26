include:
  - desktop.android.sdk

{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% set marker = "# saltstack android development automatic config" %}
{% set start = marker+ " start" %}
{% set end = marker+ " end" %}

android-create-user-profile:
  file:
    - touch
    - name: {{ user_home }}/.profile

android-accept-license-user:
{#
# accept the license agreements of the SDK components
ADD license_accepter.sh /opt/
RUN chmod +x /opt/license_accepter.sh && /opt/license_accepter.sh $ANDROID_HOME
#}

android-modify-user-profile:
  file.blockreplace:
    - name: {{ user_home }}/.profile
    - marker_start: "{{ start }}"
    - marker_end: "{{ end }}"
    - contents: |
        # set the environment variables
        # ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
        # ENV GRADLE_HOME /opt/gradle
        # ENV KOTLIN_HOME /opt/kotlinc
        # ENV PATH ${PATH}:${GRADLE_HOME}/bin:${KOTLIN_HOME}/bin:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/tools/bin
        # ENV _JAVA_OPTIONS -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
        # WORKAROUND: for issue https://issuetracker.google.com/issues/37137213
        # ENV LD_LIBRARY_PATH ${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib

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


#android-create-avd:
#  cmd.run:
#    - name: 'echo -en "no\n" | android create avd --force --snapshot -n test -t android-19'

#android-run-avd:
#  cmd.run:
#    - name: 'emulator -gpu on -memory 1024 @test'
