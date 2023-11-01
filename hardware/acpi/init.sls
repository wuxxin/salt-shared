acpid:
  pkg.installed:
    - pkgs:
      - acpid
  service.running:
    - name: acpid
    - enable: true
    - require:
      - pkg: acpid
