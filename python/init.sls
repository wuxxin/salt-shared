{% from 'python/lib.sls' import pip3_install %}

python:
  pkg.installed:
    - pkgs:
      - python3
      - python3-pip
      - python3-setuptools
      - python3-venv
      - python3-virtualenv
      - virtualenv

{# python3-pip is usually to old, upgrade it after install #}
pip3-upgrade:
  cmd.run:
    - name: pip3 install -U pip
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"

{# make a chain call in case there is no more recent version of pip #}
pip3-chain:
  cmd.run:
    - name: printf '#!/usr/bin/sh\nexec /usr/bin/pip3 $@\n'> /usr/local/bin/pip3; chmod +x /usr/local/bin/pip3
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"
    - require:
      - cmd: pip3-upgrade

{# unconditionaly set python to python3 #}
update-python-alternative:
  cmd.run:
    - name: update-alternatives --install /usr/bin/python python /usr/bin/python3 50
    - unless: test $(readlink -f /usr/bin/python) = $(readlink -f /usr/bin/python3)
    - require:
      - pkg: python

{# Install and Run Python Applications in Isolated Environments #}
{{ pip3_install('pipx') }}
