{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("haproxy-ppa", 
  "vbernat/haproxy-1.5", require_in= "pkg: haproxy") }}
{% endif %} 

{% from "roles/haproxy/defaults.jinja" import template with context %}
{% set haproxy=salt['grains.filter_by']({'none': template.haproxy }, 
  grain='none', default= 'none', merge= pillar.haproxy|d({})) %}

{% for a in ['http_ssl_to_http', 'http_ssl_to_http_ssl', 'http_to_http', 'redirect_to_http_ssl'] %}
/etc/haproxy/{{a }}:
  file.directory:
    - makedirs: true
    - require:
      - pkg: haproxy
    - require_in:
      - file: haproxy
{% endfor %}

# FIXME: add dh_param (size 2048) for each cert on install! openssl dhparam 2048
# TODO: haproxy crt staple is: cert+privkey+intermediate+dhparam

haproxy:
  pkg:
    - installed
  service.running:
    - enable: true
    - require:
      - pkg: haproxy
  file.managed:
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://roles/haproxy/haproxy.cfg
    - template: jinja
    - context: {{ haproxy }}
    - watch_in:
      - service: haproxy
