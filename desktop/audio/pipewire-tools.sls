{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.audio.framework
  - python.meson

{% if grains['os'] == 'Ubuntu' and grains['osmajorrelease'] >= 20 %}

wireplumber-req:
  pkg.installed:
    - pkgs:
      - build-essential
      - libpipewire-0.3-dev
      - libspa-0.2-dev
    - require:
      - sls: desktop.audio.framework
      - sls: python.meson

wireplumber:
  file.directory:
    - name: {{ user_home }}/.local/src/
    - user: {{ user }}
    - group: {{ user }}
  git.latest:
    - name: https://gitlab.freedesktop.org/pipewire/wireplumber.git
    - user: {{ user }}
    - target: {{ user_home }}/.local/src/wireplumber
    - require:
      - pkg: wireplumber-req
      - file: wireplumber
  cmd.run:
    - cwd: {{ user_home }}/.local/src/wireplumber
    - runas: {{ user }}
    - name: |
        meson build . --prefix=/usr
        ninja -C build
    - onchanges:
      - git: wireplumber

wireplumber_install:
  cmd.run:
    - name: ninja -C {{ user_home }}/.local/src/wireplumber/build install
    - onchanges:
      - cmd: wireplumber

{% endif %}
