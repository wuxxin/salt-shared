include:
  - vcs.git
  - java.jdk
  - .init

{% from 'roles/desktop/user/lib.sls' import user, user_info, user_home with context %}


p4a:
  pkg.installed:
    - pkgs:
      - cython
      - ant
      - zlib1g-dev
      - build-essential
  git.latest:
    - name: https://github.com/kivy/python-for-android.git
    - target: {{ user_home }}/p4a
    - runas: {{ user }}
    - submodules: True
    - require:
      - pkg: p4a
      - pkg: git
      - pkg: default-jdk
      - file: android-modify-user-profile
  cmd.run:
    - name: ./distribute.sh -m "openssl pil kivy"
    - cwd: {{ user_home }}/p4a
    - runas: {{ user }}
    - unless: test -e {{ user_home }}/p4a/dist/default
    - require:
      - git: p4a
