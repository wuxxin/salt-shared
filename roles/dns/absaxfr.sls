
{% for u in ("axfrdns",) %}
{{ u }}_remove:
  cmd.run:
    - name: update-service --remove /etc/sv/{{ u }}
    - onlyif: test -e /etc/service/{{ u }}
    - require:
      - cmd: {{ u }}_service

{{ u }}_service:
   cmd.run:
    - name: svc -d /etc/service/{{ u }}
    - onlyif: test -e /etc/service/{{ u }}
{% endfor %}
