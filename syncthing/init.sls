include:
  - ubuntu
  
syncthing:
  pkgrepo.managed:
    - name: deb https://apt.syncthing.net/ syncthing stable
    - file: /etc/apt/sources.list.d/syncthing.list
    - key_url: https://syncthing.net/release-key.txt
    - require_in:
      - pkg: syncthing
    - require:
      - sls: ubuntu
  pkg.installed:
    - pkgs:
      - syncthing
