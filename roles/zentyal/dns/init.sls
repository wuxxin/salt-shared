# ### bind

{% if salt['pillar.get']('zentyal:dns:status', "absent") == "present" %}

/etc/zentyal/hooks/dns.postsetconf:
  file.managed:
    - source: salt://roles/zentyal/dns/dns.postsetconf
    - template: jinja
    - makedirs: true
    - context:
      dns: {{ pillar.zentyal.dns }}
    - mode: 755
#    - require:
#      - pkg: zentyal

{% if pillar.zentyal.dns.zones_new|d(False) != False %}
{% for n,d in pillar.zentyal.dns.zones_new.iteritems() %}
{% set s,t=d %}
{{ n }}_file:
  file.managed:
    - source: {{ s }}
    - name: {{ t }}
    - mode: 644
#    - require:
#      - pkg: zentyal
{% endfor %}
{% endif %}

{% if pillar.zentyal.dns.zones_append|d(False) != False %}
{% for n,d in pillar.zentyal.dns.zones_append.iteritems() %}
{% set s,i,t=d %}
{{ n }}_file:
  file.managed:
    - source: {{ s }}
    - name: {{ i }}
    - mode: 644
#    - require:
#      - pkg: zentyal
{% endfor %}
{% endif %}


/opt/samba4/private/dns_update_list.template:
  file.managed:
    - source: salt://roles/zentyal/dns/dns_update_list
    - mode: 644

{% if pillar.zentyal.dns.zones_samba|d(False) != False %}
{% for n,d in pillar.zentyal.dns.zones_samba.iteritems() %}
{% set s,t=d %}
{{ n }}_file:
  file.managed:
    - source: {{ s }}
    - name: {{ t }}
    - mode: 644
    - require:
      - file: /opt/samba4/private/dns_update_list.template
    - require_in:
      - cmd: update_dynamic_list
#    - require:
#      - pkg: zentyal
{% endfor %}

update_dynamic_list:
  cmd.run:
    - name: cat /opt/samba4/private/dns_update_list.template {% for n,d in pillar.zentyal.dns.zones_samba.iteritems() %}{% set s,t=d %}{{ t }} {% endfor %} > /opt/samba4/private/dns_update_list
    - require: 
      - file: /opt/samba4/private/dns_update_list.template

{% endif %}

{% endif %}
