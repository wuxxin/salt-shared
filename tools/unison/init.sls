{% if grains['lsb_distrib_codename'] in ['trusty', 'precise'] %}
  {% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("unison_backports_ppa", 
  "apw/unison-backports", require_in= "pkg: unison") }}
{% endif %}

unison:
  pkg:
    - installed
