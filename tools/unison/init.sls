{% if grains['oscodename'] in ['trusty', 'precise'] %}
  {% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("unison_backports_ppa", 
  "apw/unison-backports", require_in= "pkg: unison") }}
{% endif %}

unison:
  pkg:
    - installed
