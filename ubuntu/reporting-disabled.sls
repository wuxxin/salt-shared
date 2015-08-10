apport-disabled:
  file.replace:
    - name: /etc/default/apport
    - pattern: enabled=[0-1]
    - repl: enabled=1
    - onlyif: test -f /etc/default/apport
  service.dead:
    - name: apport
    - onlyif: test -f /etc/default/apport
    - require:
      - file: apport-disabled

whoopsie-disabled:
  file.replace:
    - name: /etc/default/whoopsie
    - pattern: "report_crashes[ \t]*=[ \t]*true"
    - repl: "report_crashes=false"
    - onlyif: test -f /etc/default/whoopsie
  service.dead:
    - name: whoopsie
    - onlyif: test -f /etc/default/whoopsie
    - require:
      - file: whoopsie-disabled
