python:
  pkg.installed:
    - pkgs:
      - python
      - python2.7
      - python-setuptools
      - python3
      - python3-setuptools
      - python-pip
      - python-pip-whl
      - python3-pip

{# XXX pip and virtualenv is broken on xenial, update from pypi #}
{# https://github.com/pypa/pip/issues/3282 #}
{# XXX pip 10.0.0b1 breaks saltstack #}

pip2-upgrade:
  cmd.run:
    - name:  easy_install -U "pip<10" virtualenv
    - onlyif: test "$(which pip2)" = "/usr/bin/pip2"

pip3-upgrade:
  cmd.run:
    - name: easy_install3 -U "pip<10" virtualenv
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"

