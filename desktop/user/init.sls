
{% from 'desktop/user/lib.sls' import user, user_info, user_home, add_to_groups with context %}

{{ add_to_groups(['users']) }}

add_local_bin:
  file.directory:
    - name: {{ user_home }}/bin
    - user: {{ user }}
    - group: {{ user }}


