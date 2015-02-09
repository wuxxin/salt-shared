
{% for a in ['etcd'] %}
/usr/local/bin/{{ a }}:
  file:
    - absent
{% endfor %}
