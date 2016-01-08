include:
  - java
  - .user
  - .android
  - .audio
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
  - .sonic-pi


{% if salt['pillar.get']('desktop:development:status', 'absent') == 'present' %}
  - .vcs
  - .python
  - .gcloud
  - .atom
  - .emulation
  - .homeshick
  - .writing
  - .time
  - .paste
  - .scipy
{% endif %}

{% if salt['pillar.get']('desktop:games:status', 'absent') == 'present' %}
  - .emulation.games
{% endif %}

{% if salt['pillar.get']('desktop:bitcoin:status', 'absent') == 'present' %}
  - .bitcoin
{% endif %}

{#
general:
  - .email
  - .power

developer:
  - .kivy
  - .tmbundles
  - .openwrt
  - .idea
  - .etckeeper
  - .android.sdk
  - .android.user
  - .eclipse
  - .arduino

#sysdig:
#  pkg:
#    - installed
#minidlna:
#  pkg:
#    - installed

#}
