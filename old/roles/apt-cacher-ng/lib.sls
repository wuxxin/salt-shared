
{% if salt['pillar.get']('apt-cacher-ng:client:status', 'absent') == 'present' %}
  {% if salt.pillar.get('apt-cacher-ng:client:override_address', false) != false %}
    {% set proxy_address = 'http://'+ salt.pillar.get('apt-cacher-ng:client:override_address')+ ':3142' %}
  {% else %}
    {% set proxy_address = 'http://'+ salt.mine.get('apt-cacher-ng:server:status:present', 'get_fqdn', expr_form='pillar')[0]+ ':3142' %}
  {% endif %}
{% else %}
  {% set proxy_address = false %}
{% endif %}
