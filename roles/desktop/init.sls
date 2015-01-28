include:
  - java
  - .user
  - .bitcoin
  - .browser
  - .chat
  - .chipcard
  - .email
  - .fixes
  - .ftp
  - .graphics
  - .mozilla
  - .network
  - .power
  - .security
  - .terminal
  - .ubuntu
  - .video-audio
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

