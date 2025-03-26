{% from 'arch/lib.sls' import aur_install with context %}
{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}
{% from 'python/lib.sls' import pipx_install %}

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
      ### MITM
      # FIXME-BUILD WORKS AS USER frida - Dynamic instrumentation toolkit for developers, reverse-engineers, and security researchers
      - python-frida
      # python-frida-tools - CLI tools for Frida. Python 3 version from PyPi
      - python-frida-tools
      ### NFC
      # mfoc - MiFare Classic Universal toolKit
      - mfoc
{% endload %}
{{ aur_install("security-tools-aur", pkgs) }}


# security-tools-pipx

{# pipx_install('xxx', user=user) #}
