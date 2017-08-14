include:
  - python
{% if devnames %}
  - python.dev
{% endif %}

{% load_yaml as names %}
- percol
{% endload %}

{% load_yaml as devnames %}
- cgroup-utils
{% endload %}

{% for n in names %}
pip2_install(n)
{% endfor %}

{% for n in devnames %}
pip2_install(n, requires= ['sls: python.dev'])
{% endfor %}
