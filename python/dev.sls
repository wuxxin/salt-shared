include:
  - python
  - python.ipython

python-dev:
  pkg.installed:
    - pkgs:
      - python3-dev
    - require:
      - sls: python

{% from 'python/lib.sls' import pip3_install %}

python-tools:
  pkg.installed:
    - pkgs:
      - python3-pudb      {# full-screen console debugger for Python #}
      - python3-isort
      - isort             {# sort imports and automatically separated into sections #}
{%- if grains['osmajorrelease']|int >= 18 %}
      - python3-mypy
      - mypy              {# use mypy to type check type annotations #}
      - python3-yapf
      - yapf3             {# takes the code and reformats it #}
{%- endif %}
{%- if grains['osmajorrelease']|int < 18 or grains['osrelease'] == '18.04' %}
      - python-autopep8
{%- else %}
      - python3-autopep8  {# formats Python code to conform to the PEP 8 style guide #}
{%- endif %}

{# - repren     Multi-pattern string replacement and file renaming #}

{#
{{ pip3_install('git+https://github.com/peo3/cgroup-utils.git#cgroup-utils', require= ['pkg: python-dev']) }}
#}
{{ pip3_install('cgroup-utils>=0.6', require= ['pkg: python-dev']) }}
