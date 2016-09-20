{% load_yaml as names %}
- percol
{% endload %}

{% load_yaml as devnames %}
- cgroup-utils
{% endload %}

include:
{% if devnames %}
  - python.dev
{% else %}
  - python
{% endif %}

{% for n in names %}
pip-{{ n }}:
  pip.installed:
    - name: {{ n }}
    - require:
      - sls: python
{% endfor %}

{% for n in devnames %}
pip-{{ n }}:
  pip.installed:
    - name: {{ n }}
    - require:
      - sls: python-dev
{% endfor %}
