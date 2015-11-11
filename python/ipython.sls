include:
  - python

{% for a in ('ipython', 'jupyter') %}
{{ a }}:
  pip.installed:
    - require:
      - sls: python
{% endfor %}
