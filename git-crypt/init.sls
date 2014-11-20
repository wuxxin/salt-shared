include:
  - git
  - openssl

{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/git-crypt' %}


# TODO: make a debian package out of it and install it to a personal archive
{% if salt['cmd.run_stdout']('which git-crypt') == "" %}
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

{% else %}

git-crypt:
  cmd.run:
    - name: "which git-crypt"

{% endif %}