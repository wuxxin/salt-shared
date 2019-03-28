include:
  - java
  
{% set arduino_user = pillar['arduino_user']|default('arduino') %}

arduino:
  archive:
    - extracted
    - name: /home/{{ arduino_user }}
{% if grains['cpuarch'] = 'x86_64' %}
    - source: http://arduino.cc/download_handler.php?f=/arduino-1.6.0-linux64.tar.xz
{% else %}
    - source: http://arduino.cc/download_handler.php?f=/arduino-1.6.0-linux32.tar.xz
{% endif %}
    - archive_format: tar
    - tar_options: z
    - if_missing: /home/{{ arduino_user }}/arduino-1.6.0
    - require:
      - pkg: default-jre

#http://www.pjrc.com/teensy/td_113/teensyduino.64bit
#http://www.pjrc.com/teensy/td_113/teensyduino.32bit
#http://www.pjrc.com/teensy/49-teensy.rules
#http://www.pjrc.com/teensy/teensy_loader_cli.2.0.tar.gz
