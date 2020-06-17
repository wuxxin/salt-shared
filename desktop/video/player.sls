{% from 'python/lib.sls' import pip3_install %}

include:
  - desktop.video.base
  - python

video-player:
  pkg.installed:
    - pkgs:
      - vlc
{%- if grains['osmajorrelease']|int < 18 %}
      - vlc-nox
{%- else %}
      - vlc-bin
{%- endif %}
    - require:
      - sls: desktop.video.base

{# Video/Audio downloader from webportals, eg. youtube #}
youtube-dl:
  pkg:
    - installed

{# install distro package and then update pip version #}
{{ pip3_install('youtube-dl', require='pkg: youtube-dl') }}


{# The YouTube channel checker - Command Line tool to keep track of your
    favourite YouTube channels without signing up for a Google account. #}
ytcc-req:
  pkg.installed:
    - pkgs:
      - python3-sqlalchemy
      - python3-lxml
      - python3-feedparser
    - require:
      - pkg: video-player

{{ pip3_install('git+https://github.com/woefe/ytcc.git#egg=ytcc', require='pkg: ytcc-req') }}
