include:
  - .user

unity-tweaks:
  pkg.installed:
    - pkgs:
      - unity-tweak-tool
      - compizconfig-settings-manager

apport-disabled:
  file.replace:
    - name: /etc/default/apport
    - pattern: enabled=[0-1]
    - repl: enabled=1
  service.dead:
    - name: apport
    - require:
      - file: apport-disabled

