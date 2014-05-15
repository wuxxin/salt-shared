apport-enabled:
  pkg.installed:
    - pkgs:
      - apport
  file.replace:
    - name: /etc/default/apport
    - pattern: enabled=[0-1]
    - repl: enabled=1
    - require:
      - pkg: apport-enabled
  service.present:
    - name: apport
    - require:
      - file: apport-enabled

whoopsie-enabled:
  pkg.installed:
    - pkgs:
      - whoopsie
  file.replace:
    - name: /etc/default/whoopsie
    - pattern: "report_crashes[ \t]*=[ \t]*true"
    - repl: "report_crashes=false"
    - require:
      - pkg: whoopsie-enabled
  service.present:
    - name: whoopsie
    - require:
      - file: whoopise-enabled
