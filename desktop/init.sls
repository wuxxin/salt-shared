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
  - .python.scipy
  - .python.jupyter
  - .python.fastai
  - .python.neurodsp
  - .code
  - .atom
  - .emulation
  - android.emulator-container
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
