{# configure nsswitch with a lot of systemd specific libraries #}

nsswitch.packages:
  pkg.installed:
    - pkgs:
      - libnss-resolve
      - libnss-mymachines
      - libnss-systemd
      - libnss-myhostname

nsswitch.hosts.configure:
  file.replace:
    - name: /etc/nsswitch.conf
    - pattern: |
        ^hosts:.+
    - repl: |
        hosts:          mymachines resolve [!UNAVAIL=return] files myhostname dns
    - append_if_not_found: true
