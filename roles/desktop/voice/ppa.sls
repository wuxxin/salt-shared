{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("mumble-ppa", "mumble/release") }}

jitsi-ppa:
  pkgrepo.managed:
    - name: deb https://download.jitsi.org/deb unstable/
    - key_url: salt://roles/desktop/voice/sip-communicator-keyring.gpg
    - file: /etc/apt/sources.list.d/jitsi.list
  cmd.run:
    - name: true
    - require:
      - cmd: jitsi-ppa

{% endif %} 
