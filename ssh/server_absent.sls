openssh-server:
  pkg:
    - removed
  service:
    - dead
    - name: ssh
    - require:
      - pkg: openssh-server

{% if pillar['adminkeys_absent']|d(False) or pillar['adminkeys_present']|d(False) %}
adminkeys_delete:
  ssh_auth.absent:
    - user: root
    - names:
{% for adminkey in pillar['adminkeys_present'] %}
      - "{{adminkey}}"
{% endfor %}
{% for adminkey in pillar['adminkeys_absent'] %}
      - "{{adminkey}}"
{% endfor %}
{% endif %}
