{% if grains['os'] == 'Ubuntu' %}
include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mumble_ppa", "mumble/release") }}

jitsi_ppa:
  pkgrepo.managed:
    - name: deb https://download.jitsi.org/deb unstable/
    - key_url: salt://desktop/voice/sip-communicator-keyring.gpg
    - file: /etc/apt/sources.list.d/jitsi.list
    - require:
      - pkg: ppa_ubuntu_installer

{% endif %}

voice_nop:
  test:
    - nop