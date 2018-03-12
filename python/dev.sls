include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python-dev
      - python3-dev
    - require:
      - sls: python

{% from 'python/lib.sls' import pip2_install, pip3_install %}

{% load_yaml as python_tools %}
- pudb {# full-screen console debugger for Python #}
- mypy {# Add type annotations to your Python programs, and use mypy to type check them #}
- yapf
- autopep8
- isort
- repren {# Multi-pattern string replacement and file renaming #}
{% endload %}

{% for i in python_tools %}
{{ pip3_install(i) }}
{% endfor %}

{{ pip2_install('pudb') }}
{{ pip3_install('cgroup-utils', requires= ['pkg: python3-dev']) }}
