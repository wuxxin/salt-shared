
{% set arduino_user = pillar['arduino_user']|default('arduino') %}

default-jre:
  pkg:
    - installed

arduino:
  archive:
    - extracted
    - name: /home/{{ arduino_user }}
{% if grains['cpuarch'] = 'x86_64' %}
    - source: http://arduino.googlecode.com/files/arduino-1.0.4-linux64.tgz
{% else %}
    - source: http://arduino.googlecode.com/files/arduino-1.0.4-linux32.tgz
{% endif %}
    - archive_format: tar
    - tar_options: z
    - if_missing: /home/{{ arduino_user }}/arduino-1.0.4
    - require:
      - pkg: default-jre

#http://www.pjrc.com/teensy/td_113/teensyduino.64bit
#http://www.pjrc.com/teensy/td_113/teensyduino.32bit
#http://www.pjrc.com/teensy/49-teensy.rules
#http://www.pjrc.com/teensy/teensy_loader_cli.2.0.tar.gz
