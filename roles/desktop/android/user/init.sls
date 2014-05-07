#include:
#  - roles.desktop.android

{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}

android-create-user-profile:
  file:
    - touch
    - name: {{ user_home }}/.profile

android-modify-user-profile:
  file.append:
    - name: {{ user_home }}/.profile
    - source: salt://roles/desktop/android/user/profile
    - template: jinja
    - context:
        user: {{ user }}
        user_home: {{ user_home }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: android-create-user-profile
 #     - cmd: android-sdk
 #     - cmd: android-ndk

