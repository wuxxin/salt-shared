{% from 'arch/lib.sls' import aur_install with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'code/python/lib.sls' import pipx_install %}

include:
  - android.tools

security-tools:
  pkg.installed:
    - pkgs:
      ## crypto
      ### Hashing / Dictionary / Offline Attacks
      # hashcat - Multithreaded advanced password recovery utility
      - hashcat
      # Password recovery tool for PDF-files
      - pdfcrack

      ## Network
      ### Stealth
      # curl-impersonate - A build of curl that impersonates four major browsers: Chrome, Edge, Safari & Firefox
      - curl-impersonate

      ### WIFI monitor/scan
      - tcpdump
      # wireshark - Network traffic and protocol analyzer/sniffer
      - wireshark-cli
      - termshark
      - wireshark-qt
      # bettercap - Swiss army knife for network attacks and monitoring
      - bettercap
      - bettercap-caplets
      # fping - Utility to ping multiple hosts at once
      - fping
      # nmap - Utility for network discovery and security auditing
      - nmap
      # dsniff - Collection of tools for network auditing and penetration testing
      - dsniff
      # etherape - Graphical network monitor for various OSI layers and protocols
      - etherape
      # kismet - 802.11 layer2 wireless network detector, sniffer, and intrusion detection system
      - kismet
      # masscan - TCP port scanner, spews SYN packets asynchronously, scanning entire Internet in under 5 minutes
      - masscan

      ### BlueTooth
      # bluez-utils
      - bluez-utils
      # blueman - GTK+ Bluetooth Manager
      # - blueman

      # nRF52840 related
      # nrfutil - unified command line utility for Nordic products
      - nrfutil
      # nrf5x-command-line-tools - Tools for programming Nordic nRF51, nRF52, nRF53 and nRF91 Series devices
      - nrf5x-command-line-tools
      # nrf-udev - udev rules for nRF (Nordic Semiconductor) development kits
      - nrf-udev
      # nrf-sniffer-ble - nRF Sniffer for Bluetooth LE - firmware, SnifferAPI and Wireshark plugin
      - nrf-sniffer-ble
      # nrf5x-sniffer - nRF-based 802.15.4 sniffer (firmware and Wireshark plugin)
      - nrf5x-sniffer

      ### MITM
      # sslsplit - Tool for man-in-the-middle attacks against SSL/TLS encrypted network connections
      - sslsplit
      # mitmproxy - SSL-capable man-in-the-middle HTTP proxy
      - mitmproxy

{% load_yaml as pkgs %}
      ### Network/BlueTooth
      # btscanner - Bluetooth device scanner
      # - btscanner
      # nrf-sniffer-ble - nRF Sniffer for Bluetooth LE - firmware, SnifferAPI and Wireshark plugin
      - nrf-sniffer-ble

      ### NFC
      # mfoc - MiFare Classic Universal toolKit
      - mfoc
{% endload %}
{{ aur_install("security-tools-aur", pkgs) }}
