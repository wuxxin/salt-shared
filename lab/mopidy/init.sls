
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("upmpd-ppa", 
  "jean-francois-dockes/upnpp1", require_in= "pkg: upmpdcli") }}
{% endif %}

mopidy-reqs:
  pkg.installed:
    - pkgs:
      - python-gst-1.0
      - gir1.2-gstreamer-1.0
      - gir1.2-gst-plugins-base-1.0
      - gstreamer1.0-plugins-good
      - gstreamer1.0-plugins-ugly
      - gstreamer1.0-tools

upmpdcli:
  pkg.installed:
    - pkgs:
      - upmpdcli
      - upplay

{% from 'python/lib.sls' import pip2_install, pip3_install %}
{{ pip2_install([
  'Mopidy',
  'Mopidy-Iris',
  'Mopidy-Local-Images',
  'Mopidy-Local-SQLite',
  'Mopidy-Mobile',
  'Mopidy-Moped',
  'Mopidy-Mopify',
  'Mopidy-MusicBox-Webclient',
  'Mopidy-WebSettings',
  'Mopidy-Youtube',
  'Mopidy-TuneIn',
  'Mopidy-OE1',
  ]) }}
