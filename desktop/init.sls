include:
  - java
  - .ubuntu
  - .user
  - .audio
  - .browser
  - .chat
  - .chipcard
  - .email
  - .ftp
  - .graphics
  - .health
  - .music
  - .network
  - .security
  - .spellcheck
  - .terminal
  - .video
  - .writing

{% if salt['pillar.get']('desktop:development:enabled', false) == true %}
  - python.dev
  - python.scientific
  - vcs
  - vcs.git-bridge
  - tools.extra
  - .homeshick
  - .atom
  - .code
  - .emulation
  - .android
  - .forensic
{% endif %}

{% if salt['pillar.get']('desktop:games:enabled', false) == true %}
  - .emulation.games
{% endif %}

{#
tts: ppa:msclrhd-gmail/cainteoir

sysdig:
  pkg:
    - installed
minidlna:
  pkg:
    - installed
#}
