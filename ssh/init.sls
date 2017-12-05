openssh-client:
  pkg:
    - installed

openssh-server:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - name: ssh
    - require:
      - pkg: openssh-server

{% for p,r in [
  ("UseDNS", "UseDNS no"),
  ("PasswordAuthentication", "PasswordAuthentication no"),
  ("PermitRootLogin", "PermitRootLogin yes"),
  ] %}

/etc/ssh/sshd_config_{{ p }}:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: |
        ^\s*{{ p }}.*
    - repl: |
        {{ r }}
    - append_if_not_found: true
    - require:
      - pkg: openssh-server
    - watch_in:
      - service: openssh-server
{% endfor %}

/etc/sudoers.d/ssh_auth:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        Defaults env_keep += "SSH_AUTH_SOCK"

{% from "ssh/lib.sls" import ssh_keys_update %}

{{ ssh_keys_update('root',
    salt['pillar.get']('ssh_authorized_keys', False),
    salt['pillar.get']('ssh_deprecated_keys', False)
    )
}}

