include:
  - java
  - .user
  
  - .android
  - .audio
  - .browser
{#  - .chat #}
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

{% if salt['pillar.get']('desktop:development:enabled', false) == true %}
  - python.dev
  - vcs
  - git-crypt
  - .asciinema
  - .atom
  - .code
  - .emulation
  - .homeshick
  - .gcloud
  - .scipy
  - .writing
{#
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