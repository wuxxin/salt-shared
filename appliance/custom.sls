# pin salt-stack to x.y.* release, so we get updates but no major new version
/etc/apt/preferences.d/saltstack-preferences:
  file.managed:
    - contents: |
        Package: salt-*
        Pin: version 2016.11.*
        Pin-Priority: 900
      
/etc/sudoers.d/ssh_auth_sock:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        Defaults env_keep += "SSH_AUTH_SOCK"        