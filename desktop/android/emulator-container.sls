android-emulator-container-scripts:
  pkg.installed:
    - pkgs:
      - libprotobuf-dev
      - libprotoc-dev
      - protobuf-compiler
  git.latest:
    source: https://github.com/google/android-emulator-container-scripts.git

npm i yalc -g

  cmd.run:
    - name: . ./configure; docker-emu
  cmd.run:
    - name:
