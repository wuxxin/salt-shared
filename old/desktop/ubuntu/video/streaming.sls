include:
  - desktop.ubuntu.video.framework

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("obsstudio_ppa", "obsproject/obs-studio", require_in= "pkg: video-recording-streaming") }}
{{ apt_add_repository("openshot_ppa", "openshot.developers/ppa", require_in= "pkg: video-recording-streaming") }}
{% endif %}

video-recording-streaming:
  pkg.installed:
    - pkgs:
      - openshot-qt
      - obs-studio
    - require:
      - sls: desktop.ubuntu.video.framework
