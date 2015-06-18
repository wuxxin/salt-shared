include:
  - java
  - .user
  - .browser
  - .chat
  - .chipcard
  - .ftp
  - .graphics
  - .network
  - .security
  - .terminal
  - .ubuntu
  - .video
  - .voice

{% if pillar.get('desktop.developer.status', 'absent') == 'present' %}
  - .gcloud
  - .atom
  - .emulation
  - .python
  - .vcs
{% endif %}

{% if pillar.get('desktop.games.status', 'absent') == 'present' %}
  - .emulation.games
{% endif %}

{% if pillar.get('desktop.bitcoin.status', 'absent') == 'present' %}
  - .bitcoin
{% endif %}


{#
  include:
#  - .email
#  - .power

developer:

  - .kivy
  - .tmbundles
  - .openwrt
  - .idea
  - .etckeeper
  - .android
  - .eclipse
  - .arduino

#sysdig:
#  pkg:
#    - installed

#minidlna:
#  pkg:
#    - installed

#}

