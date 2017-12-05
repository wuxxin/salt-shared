openssh-server:
  pkg:
    - removed
  service:
    - dead
    - name: ssh
    - require:
      - pkg: openssh-server

{% if pillar['ssh_deprecated_keys']|d(False) or pillar['ssh_authorized_keys']|d(False) %}
adminkeys_delete:
  ssh_auth.absent:
    - user: root
    - names:
{% for adminkey in pillar['ssh_authorized_keys'] %}
      - "{{adminkey}}"
{% endfor %}
{% for adminkey in pillar['ssh_deprecated_keys'] %}
      - "{{adminkey}}"
{% endfor %}
{% endif %}
