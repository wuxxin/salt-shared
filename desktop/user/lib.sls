{% set def_user= salt['cmd.run_stdout']('getent passwd 1000 | sed -re "s/([^:]+):.*/\\1/g"', python_shell=True) %}
{% set user= salt['pillar.get']('desktop:user', def_user) %}
{% set user_info= salt['user.info'](user) %}
{% set user_home= user_info['home'] %}
{% set user_download= user_home %}

{% macro add_to_groups(user, groups) %}
{{ user }}-add-to-groups:
  user.present:
    - name: {{ user }}
    - groups: {{ groups }}
    - remove_groups: False
{% endmacro %}

