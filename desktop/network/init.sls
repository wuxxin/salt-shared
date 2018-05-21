include:
  - .iperf3
  - .flent
    
desktop_network_packages:
  pkg.installed:
    - pkgs:
      - wireshark {# network traffic analyzer #}
      - wireshark-gtk {# GTK-Gui Version #}
      - tshark {# Text Console Version #}
      - snmp-mibs-downloader {# Install,manage Management Information Base (MIB) files #}
      - ostinato {# Packet/Traffic Generator and Analyzer #}
      - wifite {# wireless security auditing for WPA[1] and WEP using aircrack-ng tools #}
