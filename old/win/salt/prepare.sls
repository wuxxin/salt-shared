
windows_installer:
  file.managed:
    - source: http://docs.saltstack.com/downloads/Salt-Minion-2014.7.2-AMD64-Setup.exe
    - source_hash: md5=d02e8d2603079c859764203eda5a873d
    - name: /usr/local/share/windows/Salt-Minion-2014.7.2-AMD64-Setup.exe
    - makedirs: true
