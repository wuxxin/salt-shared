include:
  - desktop.video.base

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("obsstudio_ppa", "obsproject/obs-studio", require_in= "pkg: video-recording-streaming") }}
{{ apt_add_repository("openshot_ppa", "openshot.developers/ppa", require_in= "pkg: video-recording-streaming") }}

video-recording-streaming:
  pkg.installed:
    - pkgs:
      - openshot-qt
      - obs-studio
    - require:
      - sls: desktop.video.base
