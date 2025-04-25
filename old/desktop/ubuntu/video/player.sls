{% from 'code/python/lib.sls' import pip_install %}

include:
  - code.python
  - desktop.ubuntu.video.framework

dvd-css-support:
  pkg.installed:
    - name: libdvd-pkg

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
      - sls: desktop.ubuntu.video.framework
      - pkg: dvd-css-support

{# Video/Audio downloader from webportals, eg. youtube
    install distro package and then update with the pip version #}
youtube-dl:
  pkg:
    - installed

{{ pip_install('youtube-dl', require='pkg: youtube-dl') }}


{# The YouTube channel checker - Command Line tool to keep track of your
    favourite YouTube channels without signing up for a Google account. #}
ytcc-req:
  pkg.installed:
    - pkgs:
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-sqlalchemy
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-lxml
      - python{{ '3' if grains['os_family']|lower == 'debian' }}-feedparser
    - require:
      - pkg: video-player

{{ pip_install('git+https://github.com/woefe/ytcc.git#egg=ytcc', require='pkg: ytcc-req') }}
