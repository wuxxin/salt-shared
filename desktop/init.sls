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
  - .python.jupyter
  - .python.nbdev
  - .python.machinelearning
  - .python.neurodsp
  - .code
  - .atom
  - .emulation
  - android.emulator
{% endif %}

{% if salt['pillar.get']('desktop:games:enabled', false) == true %}
  - .emulation.games
{% endif %}
