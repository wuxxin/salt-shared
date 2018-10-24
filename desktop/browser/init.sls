include:
  - java.browser

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_ppa", 
  "mozillateam/ppa", require_in= "pkg: firefox") }}
{% endif %}

firefox:
  pkg.installed:
    - pkgs:
      - firefox

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser
      - chromium-codecs-ffmpeg-extra
