include:
  - python
  - .shellcheck
  
{% load_yaml as python_tools %}
- yapf
- autopep8
- isort
- repren {# Multi-pattern string replacement and file renaming #}
{% endload %}

{% from 'python/lib.sls' import pip2_install, pip3_install %}

{% for i in python_tools %}
{{ pip2_install(i) }}
{% endfor %}
