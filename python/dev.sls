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

{% load_yaml as python_tools %}
- pudb      {# full-screen console debugger for Python #}
- mypy      {# use mypy to type check type annotations #}
- yapf      {# takes the code and reformats it #}
- autopep8  {# formats Python code to conform to the PEP 8 style guide #}
- isort     {# sort imports and automatically separated into sections. #}
- repren    {# Multi-pattern string replacement and file renaming #}
{% endload %}

{% for i in python_tools %}
{{ pip3_install(i) }}
{% endfor %}

{{ pip3_install('cgroup-utils', require= ['pkg: python-dev']) }}
