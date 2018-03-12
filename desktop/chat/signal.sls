include:
  - ubuntu

signal:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://updates.signal.org/desktop/apt {{ grains['lsb_distrib_codename'] }} main
    - key_url: https://updates.signal.org/desktop/apt/keys.asc
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: signal
  pkg.installed:
    - name: signal-desktop

