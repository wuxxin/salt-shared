
bookie:
  cmd.run:
    - name: rm -r /home/bookie
    - onlyif: test -d /home/bookie
    - require:
      - user: bookie
      - group: bookie
  group:
    - absent
    - require:
      - user: bookie
  user:
    - absent
    - gid: bookie
    - home: /home/bookie
