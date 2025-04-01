{% from "server/coturn/defaults.jinja" import settings with context %}

/etc/default/coturn:
  file.managed:
    - contents: |
        #
        # Uncomment it if you want to have the turnserver running as
        # an automatic system service daemon
        #
        #TURNSERVER_ENABLED=1

/etc/turnserver.conf:
  file.managed:
    - source: salt://server/coturn/turnserver.conf
    - template: jinja
    - defaults:
        settings: {{ settings }}

coturn-snakeoil:
  pkg.installed:
    - name: ssl-cert

coturn:
  pkg.installed:
    - name: coturn
    - require:
      - pkg: coturn-snakeoil
  service.running:
    - enable: true
    - require:
      - pkg: coturn
    - watch:
      - file: /etc/default/coturn
      - file: /etc/turnserver.conf
