{% from 'manjaro/lib.sls' import pamac_install with context %}

security-tools:
  pkg.installed:
    - pkgs:
      ## crypto
      ### Hashing / Dictionary / Offline Attacks
      # hashcat - Multithreaded advanced password recovery utility
      - hashcat
      
      ## Network 
      ### monitor/scan
      - tcpdump
      # wireshark - Network traffic and protocol analyzer/sniffer
      - wireshark-cli
      - termshark
      - wireshark-qt
      # bettercap - Swiss army knife for network attacks and monitoring
      - bettercap
      - bettercap-caplets
      # dsniff - Collection of tools for network auditing and penetration testing
      - dsniff
      # etherape - Graphical network monitor for various OSI layers and protocols
      - etherape
      # masscan - TCP port scanner, spews SYN packets asynchronously, scanning entire Internet in under 5 minutes
      - masscan

      ### MITM
      # sslsplit - Tool for man-in-the-middle attacks against SSL/TLS encrypted network connections
      - sslsplit
      # mitmproxy - SSL-capable man-in-the-middle HTTP proxy
      - mitmproxy

      ### WIFI
      # deps for wifite
      # aircrack-ng - Key cracker for the 802.11 WEP and WPA-PSK protocols
      - aircrack-ng
      # reaver - WPS Pixie-Dust & brute-force attacks
      - reaver
      - hcxdumptool
      - hcxtools
      - macchanger
      # optional for wifite
      # bully - Retrieve WPA/WPA2 passphrase from a WPS enabled access point
      - bully
      - pixiewps
      # cowpatty - Wireless WPA/WPA2 PSK handshake cracking utility
      - cowpatty


{% load_yaml as pkgs %}
      ## NFC 
      # mfoc - MiFare Classic Universal toolKit
      - mfoc
      # wifite - attack multiple WEP and WPA encrypted networks
      - wifite2-git
{% endload %}
{{ pamac_install("security-tools-aur", pkgs) }}
