include:
  - java
  - .user
  - .audio
  - .browser
  - .chat
  - .chipcard
  - .ftp
  - .graphics
  - .music
  - .network
  - .power
  - .security
  - .spellcheck
  - .terminal
  - .ubuntu
  - .video
  - .voice
  - .writing

{% if salt['pillar.get']('desktop:development:enabled', false) == true %}
  - python.dev
  - vcs
  - vcs.git-bridge
  - .homeshick
  - .scipy
  - .atom
  - .code
  - .ubuntu.dev
  - .emulation
  - .android
  - .forensic

{#
  - .asciinema
  - .gcloud
  - java.jdk
  - .android.sdk
  - .android.user
  - .openwrt
  - .arduino
  - .kivy
  - .caffee
  - .neuro
#}
{% endif %}

{% if salt['pillar.get']('desktop:games:enabled', false) == true %}
  - .emulation.games
{% endif %}

{% if salt['pillar.get']('desktop:bitcoin:enabled', false) == true %}
  - .bitcoin
{% endif %}

{#
sysdig:
  pkg:
    - installed
minidlna:
  pkg:
    - installed
#}
