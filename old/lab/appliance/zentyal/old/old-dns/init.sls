# ### bind

/etc/zentyal/hooks/dns.postsetconf:
  file.managed:
    - source: salt://old/lab/appliance/zentyal/dns/dns.postsetconf
    - template: jinja
    - makedirs: true
    - context:
      dns: {{ settings.dns }}
    - mode: 755
    - require:
      - pkg: zentyal-dns

  {% if settings.dns.zones_new|d(False) != False %}
    {% for n,d in settings.dns.zones_new.iteritems() %}
      {% set s,t=d %}
{{ n }}_file:
  file.managed:
    - source: {{ s }}
    - name: {{ t }}
    - mode: 644
    - require:
      - pkg: zentyal-dns
    {% endfor %}
  {% endif %}

  {% if settings.dns.zones_append|d(False) != False %}
    {% for n,d in settings.dns.zones_append.iteritems() %}
      {% set s,i,t=d %}
{{ n }}_file:
  file.managed:
    - source: {{ s }}
    - name: {{ i }}
    - mode: 644
    - require:
      - pkg: zentyal-dns
    {% endfor %}
  {% endif %}

