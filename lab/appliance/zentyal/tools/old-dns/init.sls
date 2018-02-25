# ### bind

{% if salt['pillar.get']('appliance:zentyal:dns:status', "absent") == "present" %}

zentyal-dns:
  pkg.installed:
    - pkgs:
      - zentyal-dns
    - require:
      - pkg: zentyal

/etc/zentyal/hooks/dns.postsetconf:
  file.managed:
    - source: salt://lab/appliance/zentyal/dns/dns.postsetconf
    - template: jinja
    - makedirs: true
    - context:
      dns: {{ pillar.appliance.zentyal.dns }}
    - mode: 755
    - require:
      - pkg: zentyal-dns

  {% if pillar.appliance.zentyal.dns.zones_new|d(False) != False %}
    {% for n,d in pillar.appliance.zentyal.dns.zones_new.iteritems() %}
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

  {% if pillar.appliance.zentyal.dns.zones_append|d(False) != False %}
    {% for n,d in pillar.appliance.zentyal.dns.zones_append.iteritems() %}
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


{% endif %}
