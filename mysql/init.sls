mysql:
  pkg.installed:
    - name: mysql-server
    - python-mysqldb
  service.running:
    - enable: True
    - require:
      - pkg: mysql
  file.append:
    - name: /etc/salt/minion
    - text: "mysql.default_file: /etc/mysql/debian.cnf"
    - require:
      - service: mysql
