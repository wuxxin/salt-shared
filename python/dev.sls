include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python3-dev
    - require:
      - sls: python

{% from 'python/lib.sls' import pip2_install, pip3_install %}

{% load_yaml as python_tools %}
- pudb {# full-screen console debugger for Python #}
- mypy {# Add type annotations to your Python programs, and use mypy to type check them #}
- yapf {# takes the code and reformats it #}
- autopep8 {# automatically formats Python code to conform to the PEP 8 style guide #}
- isort {# a Python utility to sort imports and automatically separated into sections. #}
- repren {# Multi-pattern string replacement and file renaming #}
- pudb {# a full-screen, console-based visual debugger for Python #}
{% endload %}

{% for i in python_tools %}
{{ pip3_install(i) }}
{% endfor %}

{{ pip3_install('cgroup-utils', requires= ['pkg: python3-dev']) }}
