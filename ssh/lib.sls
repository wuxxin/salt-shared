{% macro ssh_keys_update(user, adminkeys_present, adminkeys_absent) %}

{% if adminkeys_present|d(False) %}
{{ user }}_adminkeys_present:
  ssh_auth.present:
    - user: {{ user }}
    - names:
{% for adminkey in adminkeys_present %}
      - "{{ adminkey }}"
{% endfor %}
{% endif %}

{% if adminkeys_absent|d(False) %}
{{ user }}_adminkeys_absent:
  ssh_auth.absent:
    - user: {{ user }}
    - names:
{% for adminkey in adminkeys_absent %}
      - "{{adminkey}}"
{% endfor %}
{% endif %}

{% endmacro %}
