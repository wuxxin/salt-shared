{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %} 

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %} 

mumble-ppa:
  pkgrepo.managed:
    - ppa: mumble/release

jitsi-ppa:
  pkgrepo.managed:
    - name: deb https://download.jitsi.org/deb unstable/
    - key_url: salt://roles/desktop/voice/sip-communicator-keyring.gpg
    - file: /etc/apt/sources.list.d/jitsi.list

{% endif %} 
