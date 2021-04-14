{% if grains['os'] == 'Ubuntu' %}
{# take nginx from ppa, because ppa is newer and stable #}
{# nginx: trusty 1.4, xenial,zesty: 1.10, artful: 1.12, ppa (2017-08): 1.12 #}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("nginx_ppa", "nginx/stable", require_in= "pkg: nginx") }}
{% endif %}

nginx:
  pkg:
    - installed
