python:
  pkg.installed:
    - pkgs:
      - python3
      - python3-pip
      - python3-setuptools
      - python3-venv
      - python3-virtualenv
      - virtualenv

{# python3-pip is at 9.x on cosmic (therefore bionic) and earlier, and 18.x* on disco and later #}
pip3-upgrade:
  cmd.run:
    - name: pip3 install -U pip
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"

{# unconditionaly set python to python3 #}
update_python_alternative:
  cmd.run:
    - name: update-alternatives --install /usr/bin/python python /usr/bin/python3 50
    - unless: test $(readlink -f /usr/bin/python) = $(readlink -f /usr/bin/python3)
    - require:
      - pkg: python
