hostname:
  file:
    - managed
    - name: /etc/hostname
    - user: root
    - group: root
    - mode: 444
    - content:
        {{ pillar['hostname'] }}
  host:
    - present
    - name: {{ pillar['hostname'] }}
    - ip: 127.0.0.1
  cmd:
    - wait
    - stateful: False
    - name: hostname `cat /etc/hostname`
    - watch:
      - file: hostname
