{% from 'arch/lib.sls' import aur_install with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

include:
  - desktop.manjaro.emulator
  - desktop.python

embedded-tools:
  pkg.installed:
    - pkgs:
      # platformio-core - An open source ecosystem for IoT development
      - platformio-core
      - platformio-core-udev
      # esptool - A cute Python utility to communicate with the ROM bootloader in Espressif ESP8266
      - esptool
{% load_yaml as pkgs %}
      # esp-idf - Espressif IoT Development Framework. Official development framework for ESP32
      - esp-idf
      # esphome - Solution for your ESP8266/ESP32 projects with Home Assistant
      - esphome
      # esphome-flasher - ESP8266/ESP32 firmware flasher GUI for ESPHome
      - esphome-flasher
      # rshell - remote shell for working with MicroPython boards
      - rshell-micropython-git
{% endload %}
{{ aur_install("embedded-tools-aur", pkgs) }}