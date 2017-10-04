include:
  - .zentyal
  - .mail
  - .user

zentyal_first_backup:
  cmd.run:
    - name: /usr/share/zentyal/make-backup
    - require:
      - sls: .zentyal
      - sls: .mail
      - sls: .user
