include:
  - git
  - openssl

{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/git-crypt' %}


# FIXME: need to look if git-crypt is already installed (as debian package) and skip rest if so

git-crypt:
  pkg.installed:
    - pkgs:
      - libssl-dev
      - build-essential
      - git-buildpackage
      - debhelper
  git.latest:
    - name: https://github.com/AGWA/git-crypt.git
    - target: {{ workdir }}
    - require:
      - pkg: git
      - pkg: openssl
      - pkg: git-crypt
  file.recurse:
    - name: {{ workdir }}/debian
    - source: salt://git-crypt/debian
    - require:
      - git: git-crypt
  cmd.run:
    - cwd: {{ workdir }}
    - name: "git-buildpackage -uc -us --git-ignore-new && DEBIAN_FRONTEND=noninteractive dpkg -i `ls {{ tempdir }}/*.deb`"
    - require:
      - file: git-crypt

git-crypt-cleanup:
  file.absent:
    - name: {{ tempdir }}
    - require:
      - cmd: git-crypt

