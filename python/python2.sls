python2:
  pkg.installed:
    - pkgs:
      - python
      - python2.7
      - python-setuptools

pip2-upgrade:
  cmd.run:
    - name: pip2 install -U pip virtualenv
    - onlyif: test "$(which pip2)" = "/usr/bin/pip2"
