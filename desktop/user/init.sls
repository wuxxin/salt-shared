
{% from 'desktop/user/lib.sls' import user, user_info, user_home, add_to_groups with context %}

{{ add_to_groups(['users']) }}

{% for key in ['bin', '.local/bin', '.local/lib', '.local/share'] %}
add_local_{{ key }}:
  file.directory:
    - name: {{ user_home }}/{{ key }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: true
{% endfor %}


