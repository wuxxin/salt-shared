{# get 2.2 for bionic or focal from ppa, > focal have 2.2 already #}
{# buster has 2.2 in backports, bullseye has 2.2 already #}

{% if grains['os'] == 'Ubuntu' %}
{% if grains['oscodename'] in ['bionic', 'focal'] %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("haproxy_ppa", "vbernat/haproxy-2.2", require_in = "pkg: haproxy") }}
{% endif %}
{% endif %}

haproxy:
  pkg:
    - installed
