{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

{# also see https://github.com/pierlon/scrcpy-docker #}

include:
  - android.tools
  - python.meson
  - vcs.git

scrcpy-req:
  pkg.installed:
    - pkgs:
      - build-essential
      - pkg-config
      - ffmpeg
      - libsdl2-2.0-0
      - libavcodec-dev
      - libavformat-dev
      - libavutil-dev
      - libsdl2-dev
    - require:
      - sls: android.tools
      - sls: python.meson
      - sls: vcs.git

scrcpy-source:
  file.directory:
    - name: {{ user_home }}/.local/src/scrcpy
    - user: {{ user }}
    - group: {{ user }}
  git.latest:
    - name: https://github.com/Genymobile/scrcpy.git@v1.17
    - user: {{ user }}
    - target: {{ user_home }}/.local/src/scrcpy
    - require:
      - pkg: scrcpy-req
      - file: scrcpy-source

scrcpy-server:
  file.managed:
    - source: https://github.com/Genymobile/scrcpy/releases/download/v1.17/scrcpy-server-v1.17
    - hash_url: https://github.com/Genymobile/scrcpy/releases/download/v1.17/SHA256SUMS.txt
    - name: {{ user_home }}/.local/lib/scrcpy-server
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true

scrcpy-build:
  cmd.run:
    - cwd: {{ user_home }}/.local/src/scrcpy
    - runas: {{ user }}
    - name: |
        BUILDDIR=build
        rm -rf "$BUILDDIR"
        meson "$BUILDDIR" --buildtype release --strip -Db_lto=true \
          -Dprebuilt_server={{ user_home }}/.local/lib/scrcpy-server
        cd "$BUILDDIR"
        ninja
    - onchanges:
      - git: scrcpy-source
      - file: scrcpy-server

scrcpy-install:
  cmd.run:
    - cwd: {{ user_home }}/.local/src/scrcpy/build
    - runas: {{ user }}
    - name: |
        ninja install
        meson build . --prefix=/usr
        ninja -C build
    - onchanges:
      - cmd: scrcpy
