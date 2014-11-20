include:
  - .client

openssh-server:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - name: ssh
    - require:
      - pkg: openssh-server

{% if pillar['adminkeys_present']|d(False) %}
adminkeys_present:
  ssh_auth.present:
    - user: root
    - names:
{% for adminkey in pillar['adminkeys_present'] %}
      - "{{adminkey}}"
{% endfor %}
{% endif %}

{% if pillar['adminkeys_absent']|d(False) %}
adminkeys_absent:
  ssh_auth.absent:
    - user: root
    - names:
{% for adminkey in pillar['adminkeys_absent'] %}
      - "{{adminkey}}"
{% endfor %}
{% endif %}

