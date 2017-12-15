{% if salt['pillar.get']('desktop:commercial:enabled', false) == true %}
include:
  - .skype
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mumble_ppa", 
  "mumble/release", require_in= "pkg: mumble") }}

jitsi_ppa:
  pkgrepo.managed:
    - name: deb https://download.jitsi.org/deb unstable/
    - key_url: salt://desktop/voice/sip-communicator-keyring.gpg
    - file: /etc/apt/sources.list.d/jitsi.list
    - require_in:
      - pkg: jitsi

{% endif %}

mumble:
  pkg:
    - installed

jitsi:
  pkg:
    - installed

linphone:
  pkg:
    - installed
