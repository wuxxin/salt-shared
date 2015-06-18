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
#  - .email
#  - .power

{% if pillar.get('desktop.developer.status', 'absent') == 'present' %}
  - .gcloud
  - .atom
  - .emulation
  - .python
  - .vcs
{% endif %}

{#
  - .kivy
  - .tmbundles
  - .openwrt
  - .idea
  - .etckeeper
  - .android
  - .eclipse
  - .arduino
#}

{% if pillar.get('desktop.games.status', 'absent') == 'present' %}
  - .emulation.games
{% endif %}

{% if pillar.get('desktop.bitcoin.status', 'absent') == 'present' %}
  - .bitcoin
{% endif %}


#sysdig:
#  pkg:
#    - installed

#minidlna:
#  pkg:
#    - installed

