{% load_yaml as names %}
- percol
{% endload %}

{% load_yaml as devnames %}
- cgroup-utils
{% endload %}

include:
  - python
{% if devnames %}
  - python.dev
{% endif %}

{% from 'python/lib.sls' import pip2_install, pip3_install %}

{% for n in names %}
{{ pip2_install(n) }}
{% endfor %}

{% for n in devnames %}
{{ pip2_install(n, requires= ['sls: python.dev']) }}
{% endfor %}
