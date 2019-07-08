{% from 'python/lib.sls' import pip3_install %}
include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python3-dev
      - cython3
    - require:
      - sls: python

python-tools:
  pkg.installed:
    - pkgs:
      - python3-pudb    {# full-screen console debugger for Python #}
      - python3-isort
      - isort           {# sort imports separated into sections #}
{%- if grains['osmajorrelease']|int >= 18 %}
      - python3-mypy
      - mypy            {# type check type annotations #}
      - python3-yapf
      - yapf3           {# code audit and reformating #}
      - python3-pylama
      - pylama          {# code audit and reformating for Python #}
{%- endif %}

{%- if grains['osmajorrelease']|int < 18 or grains['osrelease'] == '18.04' %}
      - python-autopep8
{%- else %}
      - python3-autopep8  {# code audit and reformating to PEP 8 style #}
{%- endif %}

black:
  pkg.installed:
    - pkgs:
      - python3-appdirs
      - python3-attr {# XXX python package is named attrs not attr #}
      - python3-click
      - python3-toml
{# opinionated python source code formating #}
{{ pip3_install('black', require='pkg: black') }}

{# - repren     Multi-pattern string replacement and file renaming #}
{{ pip3_install('cgroup-utils>=0.6', require= ['pkg: python-dev']) }}
