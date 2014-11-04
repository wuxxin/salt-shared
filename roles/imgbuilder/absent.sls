
imgbuilder:
  cmd.run:
    - name: rm -r /home/imgbuilder
    - onlyif: test -d /home/imgbuilder
  user:
    - absent
    - gid: imgbuilder
    - home: /home/imgbuilder
    - require:
      - cmd: imgbuilder
  group:
    - absent
    - require:
      - user: imgbuilder

vagrant:
  pkg:
    - removed

