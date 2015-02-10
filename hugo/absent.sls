
{% for a in ['hugo'] %}
/usr/local/bin/{{ a }}:
  file:
    - absent
{% endfor %}
