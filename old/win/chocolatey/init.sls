chocolatey_install:
  cmd.run:
    - name: 'powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString(\"https://chocolatey.org/install.ps1\"))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin'
    - unless: 'c:\Chocolatey\chocolateyinstall\chocolatey.cmd help'
