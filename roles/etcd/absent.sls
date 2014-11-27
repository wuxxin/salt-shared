
etcd:
  cmd.run:
    - name: rm -r /home/etcd
    - onlyif: test -d /home/etcd
  user:
    - absent
    - gid: etcd
    - home: /home/etcd
    - require:
      - cmd: etcd
  group:
    - absent
    - require:
      - user: etcd
