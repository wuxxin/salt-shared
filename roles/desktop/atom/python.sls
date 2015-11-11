include:
  - python

{% for i in ['yapf', 'isort'] %}

{{ i }}:
  pip.installed:
    - require:
      - sls: python
      - pkg: atom

{% endfor %}
