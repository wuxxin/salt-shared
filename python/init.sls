{% import_yaml "python/defaults.yml" as defaults %}
{% set settings=salt['grains.filter_by']({'default': defaults}, grain='default', 
    default= 'default', merge= salt['pillar.get']('python', {})) %}
{% from 'python/lib.sls' import pip_install %}


python:
  pkg.installed:
    - pkgs: {{ settings.python[grains['os_family']|lower] }}

{% if grains['os'] == 'Ubuntu' %}

{# pip is usually to old, upgrade it after install #}
pip3-upgrade:
  cmd.run:
    - name: pip3 install -U pip
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"
    - require_in:
      - cmd: pip3-chain

{# unconditionaly set python to python3 #}
update-python-alternative:
  cmd.run:
    - name: update-alternatives --install /usr/bin/python python /usr/bin/python3 50
    - unless: test $(readlink -f /usr/bin/python) = $(readlink -f /usr/bin/python3)
    - require:
      - pkg: python

{# make a chain call in case there is no /usr/local/bin version of pip #}
pip3-chain:
  cmd.run:
    - name: printf '#!/usr/bin/sh\nexec /usr/bin/pip3 $@\n'> /usr/local/bin/pip3; chmod +x /usr/local/bin/pip3
    - onlyif: test "$(which pip3)" = "/usr/bin/pip3"

{# Install and Run Python Applications in Isolated Environments #}
{{ pip_install('pipx') }}

{# get jinja from pypi, because > 2.9 < 2.11 is broken for saltstack #}
{{ pip_install('Jinja2>=2.11') }}

{% endif %}
