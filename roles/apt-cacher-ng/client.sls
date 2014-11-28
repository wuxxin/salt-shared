{% if salt['pillar.get']('apt-cacher-ng:server:status', 'absent') = 'present' %}
include:
  - .server

{#
we are currently on the service host, 
so if we switch to apt-get to use the proxy on the localhost, 
we need to be sure it is already running the service
#}

{% endif %}


/etc/apt/apt.conf.d/02proxy:
  file.managed:
{% if salt['pillar.get']('apt-cacher-ng:server:status', 'absent') = 'present' %}
    - require:
      - service: apt-cacher-ng
{% endif %}
    - contents: 'Acquire::http { Proxy "http://'+
salt['mine.get']('apt-cacher-ng:server:present', 'get_fqdn', expr_form='pillar')[0]+ ':3142"; };'

