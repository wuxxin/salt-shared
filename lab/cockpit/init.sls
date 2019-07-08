/etc/systemd/system/cockpit.socket.d/listen.conf:
  file.managed:
    - makedirs: true
    - contents: |
        [Socket]
        ListenStream=
        ListenStream=127.0.0.1:9090

cockpit:
  pkg.installed:
    - pkgs:
      - cockpit
    - require:
      - file: /etc/systemd/system/cockpit.socket.d/listen.conf

