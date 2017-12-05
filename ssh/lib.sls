{% macro ssh_keys_update(user, ssh_authorized_keys, ssh_deprecated_keys) %}

  {% if ssh_authorized_keys|d(False) %}
{{ user }}_ssh_authorized_keys:
  ssh_auth.present:
    - user: {{ user }}
    - names:
    {%- for adminkey in ssh_authorized_keys %}
      - "{{ adminkey }}"
    {% endfor %}
  {% endif %}

  {% if ssh_deprecated_keys|d(False) %}
{{ user }}_ssh_deprecated_keys:
  ssh_auth.absent:
    - user: {{ user }}
    - names:
    {%- for adminkey in ssh_deprecated_keys %}
      - "{{adminkey}}"
    {% endfor %}
  {% endif %}

{% endmacro %}

{% macro remove_login_as_user_keys(user) %}
{{ user }}_remove_keys_with_options:
  file.replace:
    - name: {{ salt['user.info'](user).home }}/.ssh/authorized_keys
    - pattern: |
        no.+,no.+,no.+,command=.echo..Please login as the user.+rather than the user.+;echo;sleep 10..
    - repl: ""

{% endmacro %}
