include:
  roles.zentyal
  mysql

{% set sogo_mysql_password= salt['cmd.run_stdout']('pwgen 12 1') %} 

test_for_zentyal:
  cmd.run:
    - name: test "zentyal" = {% grains['os_extra'] %}

sogo:
  pkg.installed:
    - pkgs:
      - sogo
      - memcached
      - rpl
    - require:
      - pkg: mysql
      - pkg: zentyal
      - cmd: test_for_zentyal
      - pkgrepo: sogo_ppa_ubuntu
  mysql_user.present:
    - host: localhost
    - password: {{ sogo_mysql_password }}
    - require:
      - pkg: mysql
  mysql_database:
    - present
    - require:
      - pkg: mysql
  mysql_grants.present:
    - grant: all privileges
    - database: sogo.*
    - user: sogo
    - require:
      - mysql_user: sogo
      - mysql_database: sogo

/etc/apache2/conf.d/SOGo.conf:
## adjust the following to your configuration
#  RequestHeader set "x-webobjects-server-port" "443"
#  RequestHeader set "x-webobjects-server-name" "yourhostname"
#  RequestHeader set "x-webobjects-server-url" "https://yourhostname"
    - require:
      pkg: sogo

apache_enable_sogo_modules:
  cmd
# a2enmod proxy proxy_http headers rewrite
    - require:
      - file: /etc/apache2/conf.d/SOGo.conf

/home/sogo/sogo.script:
  file.managed:
    - source: salt://roles/sogo-zentyal/sogo.script
    - template: jinja
    - context:
      timezone: {{ pillar.timezone }}
      fullhostname: 
      adminusername:
      baseDN:
      bindDN:
      bindDNpassword:
      sogo_mysql_password: {{ sogo_mysql_password }}
    - require:
      - pkg: sogo


# chmod +x /home/sogo/sogo.script
# as sogo: /home/sogo/sogo.script

#service apache2 restart
#
