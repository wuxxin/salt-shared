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

{% if salt['pillar.get']('desktop:development:status', 'absent') == 'present' %}
  - .gcloud
  - .atom
  - .emulation
  - .python
  - .vcs
{% endif %}

{% if salt['pillar.get']('desktop:games:status', 'absent') == 'present' %}
  - .emulation.games
{% endif %}

{% if salt['pillar.get']('desktop:bitcoin:status', 'absent') == 'present' %}
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

