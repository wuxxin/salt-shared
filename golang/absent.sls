golang:
  pkg:
    - removed
  cmd.run:
    - name: rm -r /home/go_builder
    - onlyif: test -d /home/go_builder
  user:
    - absent
    - name: go_builder
    - gid: go_builder
    - home: /home/go_builder
    - require:
      - cmd: golang
  group:
    - absent
    - name: go_builder
    - require:
      - user: go_builder
