openvpn:
  pkg.removed:
    - pkgs:
      - openvpn
  service.dead:
    - require:
      - pkg: openvpn
  cmd.run:
    - name: update-rc.d -f openvpn remove
    - require:
      - service: openvpn
  file.absent:
    - name: /etc/openvpn/
    - require:
      - cmd: openvpn


