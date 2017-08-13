remote_desktop:
  module.run:
    - name: rdp.enable
    - require:
      - cmd: remote_desktop_firewall

remote_desktop_firewall:
  cmd.run:
    - name: "netsh firewall set service type = remotedesktop mode = enable"

# 'reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f'
