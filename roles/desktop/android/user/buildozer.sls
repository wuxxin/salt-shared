include:
  - python
  - git
  - java.jdk
  - .init

{% from 'roles/desktop/user/lib.sls' import user, user_home with context %}

buildozer:
  pkg.installed:
    - pkgs:
      - cython
      - ant
      - zlib1g-dev
      - build-essential
  file.directory:
    - name: {{ user_home }}/.buildozer/android
    - user: {{ user }}
    - group: {{ user }}
  virtualenv.managed:
    - name: {{ user_home }}/.buildozer/env
    - user: {{ user }}
    - runas: {{ user }}
    - system_site_packages: False
    - cwd: {{ user_home }}/.buildozer
    - require:
      - file: buildozer
      - pkg: python
  pip.installed:
    - bin_env: {{ user_home }}/.buildozer/env
    - name: git+https://github.com/kivy/buildozer.git#egg=buildozer
    - user: {{ user }}
    - require: 
      - virtualenv: buildozer

link-sdk:
  file.symlink:
    - name: {{ user_home }}/.buildozer/android/platform/android-sdk-{{ grains['ANDROIDAPI'] }}
    - target: {{ grains['ANDROIDSDK'] }}
    - require:
      - file: buildozer

link-ndk:
  file.symlink:
    - name: {{ user_home }}/.buildozer/android/platform/android-ndk-r{{ grains['ANDROIDNDKVER'] }}
    - target: {{ grains['ANDROIDNDK'] }}
    - require:
      - file: buildozer

python-for-android:
  git.latest:
    - name: https://github.com/kivy/python-for-android.git
    - target: {{ user_home }}/.buildozer/android/platform/python-for-android
    - runas: {{ user }}
    - submodules: True
    - require:
      - file: android-modify-user-profile

buildozer-init:
  cmd.run:
    - name: . {{ user_home }}/.buildozer/env/bin/activate; buildozer init
    - cwd: {{ user_home }}/.buildozer
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - pkg: default-jdk
      - git: python-for-android
      - pip: buildozer
      - pkg: buildozer
      - file: link-sdk
      - file: link-ndk

#  cmd.run:
#    - name: . env/bin/activate; ./distribute.sh -m "openssl pil kivy"
#    - cwd: {{ user_home }}/.buildozer/
#    - user: {{ user }}
