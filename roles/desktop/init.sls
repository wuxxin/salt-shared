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


{% if salt['pillar.get']('desktop:development:status', 'absent') == 'present' %}
  - .vcs
  - .code
  - .python
  - .gcloud
  - .atom
  - .emulation
  - .homeshick
  - .writing
  - .scipy
{#
  - .android.sdk
  - .android.user
  - .openwrt
  - .arduino
  - .kivy
#}
{% endif %}

{% if salt['pillar.get']('desktop:games:status', 'absent') == 'present' %}
  - .emulation.games
{% endif %}

{% if salt['pillar.get']('desktop:bitcoin:status', 'absent') == 'present' %}
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
