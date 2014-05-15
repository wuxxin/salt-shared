apport-disabled:
  file.replace:
    - name: /etc/default/apport
    - pattern: enabled=[0-1]
    - repl: enabled=1
  service.dead:
    - name: apport
    - require:
      - file: apport-disabled

whoopsie-disabled:
  file.replace:
    - name: /etc/default/whoopsie
    - pattern: "report_crashes[ \t]*=[ \t]*true"
    - repl: "report_crashes=false"
  service.dead:
    - name: whoopsie
    - require:
      - file: whoopsie-disabled
