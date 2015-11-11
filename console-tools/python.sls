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
{{ n }}:
  pip:
    - installed
{% endfor %}

{% for n in devnames %}
{{ n }}:
  pip:
    - installed
    - require:
      - sls: python-dev
{% endfor %}
