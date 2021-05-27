{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_firefox_beta_ppa",
  "mozillateam/firefox-next", require_in= "pkg: firefox") }}
{% endif %}

firefox:
  pkg.installed:
    - pkgs:
      - firefox
      - firefox-geckodriver
