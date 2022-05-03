include:
  - .flent
  - .iperf3
  - .dns
    
desktop_network_packages:
  pkg.installed:
    - pkgs:
      - wireshark             {# network traffic analyzer #}
      - wireshark-gtk         {# GTK-Gui Version #}
      - tshark                {# Text Console Version #}
      - snmp-mibs-downloader  {# Install & manage (MIB) files #}
      - ostinato              {# Packet/Traffic Generator and Analyzer #}
      - wifite                {# wireless security auditing for WPA1 and WEP (uses aircrack-ng) #}
