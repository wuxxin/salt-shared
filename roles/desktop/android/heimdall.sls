include:
  - repo.ubuntu

heimdall:
  pkgrepo.managed:
    - name: deb http://ppa.launchpad.net/modycz/heimdall/ubuntu saucy main
    - humanname: "Ubuntu Heimdall Repository"
    - file: /etc/apt/sources.list.d/heimdall.list
    - keyid: 1ec1e8c08499ecf7a5fe1743913b07ad8ec86b93
    - keyserver: keyserver.ubuntu.com
    - require:
      - pkg: ppa_ubuntu_installer
  pkg.installed:
    - pkgs:
      - heimdall
      - android-tools-adb
      - android-tools-adbd
      - android-tools-fastboot

