include:
  - python
  - nodejs
  - java
  - android
  - hardware.chipcard
  - .ubuntu
  - .user
  - .audio
  - .browser
  - .chat
  - .email
  - .ftp
  - .flatpak
  - .graphics
  - .language
  - .music
  - .network
  - .security
  - .terminal
  - .video
  - .writing

{% if salt['pillar.get']('desktop:development:enabled', false) == true %}
  - vcs
  - tools.extra
  - .homeshick
  - .python
  - .python.scientific
  - .code
  - .atom
  - .emulation
{% endif %}

{% if salt['pillar.get']('desktop:games:enabled', false) == true %}
  - .emulation.games
{% endif %}
