{% set user= salt['pillar.get']('desktop:user', 'get-name-for-uid-1000') %}
{% set user_home= salt['user.info'](user)['home'] %}
{% set user_download= user_home %}

{% macro add_to_groups(groups) %}
{{ user }}-add-to-groups:
  user.present:
    - name: {{ user }}
    - groups: {{ groups }}
    - remove_groups: False
{% endmacro %}

