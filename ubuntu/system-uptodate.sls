update_system:
  file.replace:
    - name: /etc/update-manager/release-upgrades
    - pattern: "^Prompt=.*$"
    - repl: Prompt=never
    - order: 10
    
  pkg.uptodate:
    - refresh: True
    - require:
      - file: update_system
    - order: 10
