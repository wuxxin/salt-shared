include:
  - java.browser

{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("firefox-dev_ppa", 
  "ubuntu-mozilla-daily/firefox-aurora", require_in= "pkg: firefox") }}
{{ apt_add_repository("firefox-esr_ppa", 
  "jonathonf/firefox-esr", require_in= "pkg: firefox") }}
{% endif %}

firefox:
  pkg.installed:
    - pkgs:
      - firefox
{% if grains['os'] == 'Ubuntu' %}
      - firefox-dev
      - firefox-esr
{% endif %}

chromium-browser:
  pkg.installed:
    - pkgs:
      - chromium-browser
      - chromium-codecs-ffmpeg-extra
