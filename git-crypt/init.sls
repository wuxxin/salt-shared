include:
  - git
  - openssl

{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/git-crypt' %}

git-crypt:
  pkg.installed:
    - pkgs:
      - libssl-dev
      - build-essential
      - git-buildpackage
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
    - name: git-buildpackage -uc -us --git-ignore-new
    - require:
      - file: git-crypt

git-crypt-install:
  cmd.run:
    - name: "DEBIAN_FRONTEND=noninteractive dpkg -i `ls {{ tempdir }}/*.deb`"
    - require:
      - cmd: git-crypt

git-crypt-cleanup:
  file.absent:
    - name: {{ tempdir }}
    - require:
      - cmd: git-crypt-install




