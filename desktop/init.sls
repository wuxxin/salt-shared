include:
  - .ubuntu

  - java
  - .user
  - .audio
  - .browser
  - .chat
  - .chipcard
  - .email
  - .ftp
  - .graphics
  - .music
  - .network
  - .security
  - .spellcheck
  - .terminal
  - .video
  - .voice
  - .writing
  #   - .power

{% if salt['pillar.get']('desktop:development:enabled', false) == true %}
  - python.dev
  - vcs
  - vcs.git-bridge
  - tools.extra
  - .homeshick
  - .scipy
  - .atom
  - .code
  - .emulation
  - .android
  - .forensic

{#
  - .ubuntu.dev
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
