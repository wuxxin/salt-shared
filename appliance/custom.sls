# pin salt-stack to x.y.* release, so we get updates but no major new version
/etc/apt/preferences.d/saltstack-preferences:
  file.managed:
    - contents: |
        Package: salt-*
        Pin: version 2016.11.*
        Pin-Priority: 900

ubuntu_ppa_support:
  pkg.installed:
    - pkgs:
      - python-software-properties
      - software-properties-common
      - apt-transport-https
    - order: 10

base_packages:
  pkg.installed:
    - pkgs:
      - ca-certificates
      - acpid
      - haveged

/etc/default/locale:
  file.managed:
    - contents: |
        LANG=en_US.UTF-8
        LANGUAGE=en_US:en
        LC_MESSAGES=POSIX

set_locale:
  cmd.wait:
    - name: locale-gen en_US.UTF-8 de_DE.UTF-8
    - watch:
      - file: /etc/default/locale

      
/etc/sudoers.d/ssh_auth_sock:
  file.managed:
    - makedirs: True
    - mode: "0440"
    - contents: |
        Defaults env_keep += "SSH_AUTH_SOCK"        