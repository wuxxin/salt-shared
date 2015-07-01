include:
  - python

{% for i in ['yapf', 'isort'] %}

{{ i }}:
  pip.installed:
    - require:
      - pkg: python
      - pkg: atom

{% endfor %}
