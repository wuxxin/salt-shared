
rvm:
  group:
    - absent
  user:
    - absent
    - gid: rvm
    - home: /home/rvm
    - purge: true
    - require_in:
      - group: rvm
  cmd.run:
    - onlyif: test -f /etc/profile.d/rvm.sh
    - name: . /etc/profile.d/rvm.sh && echo -e "yes\n" | rvm implode --force
    - shell: /bin/bash

