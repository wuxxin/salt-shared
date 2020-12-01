include:
  - python
  - java
  - android
  - .ubuntu
  - .user
  - .audio
  - .browser
  - .chat
  - .chipcard
  - .email
  - .ftp
  - .flatpak
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
  - vcs
  - python.dev
  - python.scientific
  - tools.extra
  - android.emulator-container
  - .homeshick
  - .atom
  - .code
  - .emulation
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
