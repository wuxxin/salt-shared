git:
  cmd.run:
    - name: rm -r /home/git
    - onlyif: test -d /home/git
  user:
    - absent
    - gid: git
    - home: /home/git
    - require:
      - cmd: git
  group:
    - absent
    - require:
      - user: git
