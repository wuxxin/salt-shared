include:
  - git
  - openssl
{% if grains['lsb_distrib_codename']  == 'trusty' %}
  - repo.ubuntu

  {% from "repo/ubuntu.sls" import apt_add_repository %}
  {{ apt_add_repository("outsideopen_git_crypt_ppa", "outsideopen/git-crypt") }}

git-crypt:
  pkg.installed:
    - require:
      - cmd: outsideopen_git_crypt_ppa

{% else %}

git-crypt:
  pkg:
    - installed

{% endif %}


{#

# disabled
{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/git-crypt' %}


# TODO:: is disabled, we take a backport of git-crypt from a ppa for trusty and therelike
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

#}
