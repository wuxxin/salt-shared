{% set user= salt['pillar.get']('desktop:user', 'get-name-for-uid-1000') %}
{% set user_home= salt['user.info'](user)['home'] %}
{% set user_download= salt['cmd.run']('grep XDG_DOWNLOAD_DIR '+ user_home+ '.config/user-dirs.dirs | sed -re "s/[ \t]+XDG_DOWNLOAD_DIR[ \t]*=[ \t]*([^#]+)
{% set user_download= user_home if user_download == "" %}

{% macro add_to_groups(groups) %}
{{ user }}-add-to-groups:
  user.present:
    - name: {{ user }}
    - groups: {{ groups }}
    - remove_groups: False
{% endmacro %}

