{% load_yaml as settings %}
emulator:
  channel: canary
  version: 30.0.24
  url: https://dl.google.com/android/repository/emulator-linux-6723027.zip
system:
  api: P
  variant: google_apis
  abi: 28
  url: https://dl.google.com/android/repository/sys-img/google_apis/x86_64-28_r10.zip
{% endload %}

include:
  - code.python
  - desktop.android.tools

download_emulator_zip:
  file.managed:
    - source: {{ settings.emulator.url }}
    - name:

download_system_image_zip:
  file.managed:
    - source: {{ settings.system.url }}
    - name:

android_emulator_container_scripts:
  user:
    - name: androidemubuild
  pkg.installed:
    - pkgs:
      - libprotobuf-dev
      - libprotoc-dev
      - protobuf-compiler
  git.latest:
    - user: androidemubuild
    - source: https://github.com/google/android-emulator-container-scripts.git
  cmd.run:
    - runas: androidemubuild
    - name: |
        python3 -m venv venv
        ./venv/bin/pip install --upgrade pip
        ./venv/bin/pip install --upgrade setuptools
        . ./venv/bin/activate; python3 setup.py develop
        . ./venv/bin/activate; emu-docker licenses --accept
    - cwd: sourcedir
    - onchanges:
      - git: android_emulator_container_scripts

create_android_container:
  cmd.run:
    - runas: androidemubuild
    - name: . ./venv/bin/activate; emu-docker create [-h] [--extra EXTRA]
     [--dest DEST] [--tag TAG] [--repo REPO] [--push] [--gpu] [--metrics] [--no-metrics] [--start] emuzip imgzip
    - onchanges:
      - cmd: android_emulator_container_scripts

build_android_container:
  cmd.run:
    - name: podman build .
    - cwd: destcontainer
    - onchanges:
      - cmd: create_android_container
