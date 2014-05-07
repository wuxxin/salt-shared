include:
  - rvm

veewee:
  cmd.run:
    - name: rm -r /home/veewee
    - onlyif: test -d /home/veewee
    - require:
      - user: veewee
      - group: veewee
  group:
    - absent
    - require:
      - user: veewee
  user:
    - absent
    - gid: veewee
    - home: /home/veewee

veewee_gemset:
  cmd.run:
    - shell: /bin/bash
    - onlyif: test -f /etc/profile.d/rvm.sh
    - name: . /etc/profile.d/rvm.sh && rvm --force ruby-1.9.3 gemset delete veewee
    - require:
      - rvm: ruby-1.9.3
