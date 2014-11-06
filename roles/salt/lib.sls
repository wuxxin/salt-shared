
# salt - master - make
##########################

{% macro saltmaster_make(cs) %}

{% from "roles/salt/defaults.jinja" import defaults with context %}
{% set settings=salt['grains.filter_by']({'none': template },
  grain='none', default= 'none', merge= cs|d({})) %}


{% endmacro %}

