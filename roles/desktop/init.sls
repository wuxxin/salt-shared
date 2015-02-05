include:
  - java
  - .user
  - .browser
  - .chat
  - .chipcard
  - .email
  - .ftp
  - .graphics
  - .network
  - .power
  - .security
  - .terminal
  - .ubuntu
  - .video
  - .voice

{% if pillar.get('desktop.developer.status', 'absent') == 'present' %}
  - .android
  - .eclipse
  - .arduino
  - .atom
  - .emulation
  - .etckeeper
  - .idea
  - .kivy
  - .openwrt
  - .python
  - .vcs
  - .tmbundles
{% endif %}

{% if pillar.get('desktop.games.status', 'absent') == 'present' %}
  - .emulation.games
{% endif %}

{% if pillar.get('desktop.bitcoin.status', 'absent') == 'present' %}
  - .bitcoin
{% endif %}

cdargs:
  pkg:
    - installed

#sysdig:
#  pkg:
#    - installed

#minidlna:
#  pkg:
#    - installed

