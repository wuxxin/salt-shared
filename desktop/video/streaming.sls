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

{% if grains['osrelease_info'][0]|int <= 16 and 
      grains['osrelease'] != '16.10' %}
{# webcamstudio is available up to xenial and need ppa #}  
{{ apt_add_repository("webcamstudio_ppa", "webcamstudio/webcamstudio-dailybuilds", require_in="pkg: webcamstudio") }}
webcamstudio:
  pkg.installed:
    - pkgs:
      - webcamstudio
      - webcamstudio-dkms
    - require:
      - sls: desktop.video.base
{% endif %}  
