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

{# based on snapshot of 2019-11-17: Modern (OpenSSH 6.7+)
    https://infosec.mozilla.org/guidelines/openssh.html #}

{% set minimum_moduli= 3071 %}
{% for p,r in [
  ("UseDNS", "UseDNS no"),
  ("AuthenticationMethods", "AuthenticationMethods publickey"),
  ("PasswordAuthentication", "PasswordAuthentication no"),
  ("PermitRootLogin", "PermitRootLogin prohibit-password"),
  ("KexAlgorithms", "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256"),
  ("Ciphers", "Ciphers chacha20-poly1305@openssh.com,aes128-gcm@openssh.com,aes256-gcm@openssh.com"),
  ("MACs", "MACs umac-128-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com"),
  ("Subsystem\s+sftp", "Subsystem sftp  /usr/lib/ssh/sftp-server -f AUTHPRIV -l INFO"),
  ("LogLevel", "LogLevel VERBOSE"),
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

/etc/ssh/sshd_config_hostkeys:
  file.prepend:
    - name: /etc/ssh/sshd_config
    - text: |
        # Supported HostKey algorithms by order of preference.
        HostKey /etc/ssh/ssh_host_ed25519_key
        HostKey /etc/ssh/ssh_host_rsa_key
        # disabled: HostKey /etc/ssh/ssh_host_ecdsa_key
    - watch_in:
      - service: openssh-server

filter_weak_moduli:
  cmd.run:
    - name: awk '$5 >= {{ minimum_moduli }}' /etc/ssh/moduli > /etc/ssh/moduli.tmp && mv /etc/ssh/moduli.tmp /etc/ssh/moduli
    - unless: awk '$5 < {{ minimum_moduli }}{exit 1}' /etc/ssh/moduli
    - require:
      - pkg: openssh-server
    - watch_in:
      - service: openssh-server

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
