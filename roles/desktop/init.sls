include:
  - java
  - .user
  - .bitcoin
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
  - .emulator
  - .etckeeper
  - .idea
  - .kivy
  - .openwrt
  - .python
  - .vcs
  - .tmbundles
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

