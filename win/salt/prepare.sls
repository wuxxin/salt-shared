
windows_installer:
  file.managed:
    - source: http://docs.saltstack.com/downloads/Salt-Minion-2014.7.1-AMD64-Setup.exe
    - source_hash: md5=90f5755e50bc1069e577b069381e21d3
    - name: /usr/local/share/windows/Salt-Minion-2014.7.1-AMD64-Setup.exe
    - makedirs: true
