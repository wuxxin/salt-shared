{% from 'desktop/user/lib.sls' import user, user_info, user_home, add_to_groups with context %}

{{ add_to_groups(user, ['users']) }}

{% for key in ['bin', 'etc', 'lib', 'share'] %}
add_local_{{ key }}:
  file.directory:
    - name: {{ user_home }}/.local/{{ key }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
{% endfor %}
