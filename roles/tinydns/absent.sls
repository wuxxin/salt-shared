djbdns:
  pkg.removed:
    - pkgs:
      - dbndns
      - runit
    - require:
      - cmd: dnscache_remove
      - cmd: tinydns_remove

{% for u in ("Gdnscache", "Gdnslog", "Gtinydns", "Gaxfrdns") %}
{{ u }}:
  user.absent:
    - require:
      - pkg: djbdns
{% endfor %}

{% for u in ("dnscache", "tinydns", "axfrdns") %}
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
