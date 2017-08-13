include:
  - python

{% load_yaml as python_converter %}
- yapf
- autopep8
- isort
{% endload %}

{% for i in python_converter %}

{{ i }}:
  pip.installed:
    - require:
      - sls: python

{% endfor %}
