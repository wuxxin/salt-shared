include:
  - python
  - .shellcheck
  
{% load_yaml as python_converter %}
- yapf
- autopep8
- isort
{% endload %}

{% from 'python/lib.sls' import pip2_install, pip3_install %}

{% for i in python_converter %}
{{ pip2_install(i) }}
{% endfor %}
