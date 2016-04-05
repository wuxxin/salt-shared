/etc/apt/apt.conf.d/02proxy:
  file:
    - absent

{% if salt['file.file_exists']('/etc/default/docker') %}
/etc/default/docker:
  file.replace:
    - pattern: |
        ^export http_proxy=.*
    - repl: |
        #export http_proxy=""
    - backup: False
    - append_if_not_found: True
{% endif %}

/etc/profile.d/proxy.sh:
  file:
    - absent
