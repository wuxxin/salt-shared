python:
  pkg.installed:
    - pkgs:
      - python
      - python2.7
      - python-setuptools
      - python3
      - python3-pip
      - python3-setuptools
      - python3-venv

{# XXX pip and virtualenv is broken on xenial, update from pypi #}
{# https://github.com/pypa/pip/issues/3282 #}

pip2-upgrade:
  cmd.run:
    - name: pip2 install -U pip virtualenv
    - onlyif: test "$(which pip2)" = "/usr/bin/pip2"

pip3-upgrade:
  cmd.run:
    - name: pip3 install -U pip
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"

virtualenv3-upgrade:
  cmd.run:
    - name: /usr/local/bin/pip3 -U virtualenv
    - onlyif: test "$(which virtualenv)" = "/usr/bin/virtualenv"
    - require:
      - cmd: pip3-upgrade
