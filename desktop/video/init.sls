include:
  - desktop.video.base
  - desktop.video.player
  - desktop.video.streaming
  - desktop.video.editor
{%- if salt['pillar.get']('desktop:video:loopback:enabled', false) == true %}
  - desktop.video.loopback
{%- endif %}
