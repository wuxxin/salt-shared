include:
  - npm


atom:
  pkg.installed:
    - pkgs:
      - libgnome-keyring-dev
      - ctags
  git.checkout:
    - source: https://github.com/atom/atom.git
    - name: {{ user }}


git pull

rm -rf ~/.atom/
rm -rf build/node_modules

script/build
sudo script/grunt install

sudo ln -sf /lib/x86_64-linux-gnu/libudev.so.1 /lib/x86_64-linux-gnu/libudev.so.0
