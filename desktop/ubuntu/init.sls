include:
  - desktop.ubuntu.desktop
  - desktop.user
  - desktop.flatpak

  - python
  - nodejs
  - java
  - android

  - desktop.audio
  - desktop.browser
  - desktop.chat
  - desktop.email
  - desktop.ftp
  - desktop.graphics
  - desktop.language
  - desktop.music
  - desktop.network
  - desktop.security
  - desktop.terminal
  - desktop.video
  - desktop.writing

{% if salt['pillar.get']('desktop:development:enabled', false) == true %}
  - vcs
  - tools.extra
  - desktop.python
  - desktop.python.scientific
  - desktop.code
  - desktop.editor
  - desktop.emulation
{% endif %}

{% if salt['pillar.get']('desktop:games:enabled', false) == true %}
  - desktop.emulation.games
{% endif %}
