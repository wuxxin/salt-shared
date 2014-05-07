vidalia:
  pkg.installed:
    - pkgs:
      - vidalia
      - tor
      - socat
      - tor-arm
      - apparmor-utils

#  service:
#    - running
#    - require:
#      - pkg: smartmontools
#    - watch:
#      - file: /etc/default/smartmontools

#/etc/default/smartmontools:
#  file.sed:
#    - before: ^#[ ]*start_smartd=yes
#    - after: start_smartd=yes
#    - require:
#      - pkg: smartmontools

