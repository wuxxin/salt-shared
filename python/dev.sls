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

{# Install and Run Python Applications in Isolated Environments #}
{{ pip3_install('pipx') }}

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

{# autopep8 - code audit and reformating to PEP 8 style #}
{%- if grains['osmajorrelease']|int < 18 or grains['osrelease'] == '18.04' %}
      - python-autopep8
{%- else %}
      - python3-autopep8
{%- endif %}

{# black - opinionated python source code formating #}
black:
  pkg.installed:
    - pkgs:
      - python3-appdirs
      - python3-attr {# XXX python package is named attrs not attr #}
      - python3-click {# # elegant cmdline parsing #}
      - python3-toml
{{ pip3_install('black', require='pkg: black') }}

{#
python shell stuff
pip install sh        # very elegant python shell
pip install sarge     # python shell execute with "; &  | && || <>"
https://github.com/litl/rauth  # A Python library for OAuth 1.0/a, 2.0, and Ofly
pip install requests  # Python HTTP Requests for Humans
#}
