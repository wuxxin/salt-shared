include:
  - ubuntu

{% if grains['osrelease_info'][0]|int <= 19 %}

signal:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://updates.signal.org/desktop/apt {{ grains['lsb_distrib_codename'] }} main
    - key_url: https://updates.signal.org/desktop/apt/keys.asc
    - file: /etc/apt/sources.list.d/signal.org-ppa-{{ grains['lsb_distrib_codename'] }}.list
    - require:
      - pkg: ppa_ubuntu_installer
    - require_in:
      - pkg: signal
  pkg.installed:
    - name: signal-desktop

{% endif %}
