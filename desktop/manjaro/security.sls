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
      # fping - Utility to ping multiple hosts at once
      - fping
      # nmap - Utility for network discovery and security auditing
      - nmap
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

{% load_yaml as pkgs %}
      ## MITM
      # frida - Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers
      - python-frida
      ## NFC 
      # mfoc - MiFare Classic Universal toolKit
      - mfoc
{% endload %}
{{ pamac_install("security-tools-aur", pkgs) }}
