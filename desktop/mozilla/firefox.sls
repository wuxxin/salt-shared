{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_firefox_beta_ppa", 
  "mozillateam/firefox-next", require_in= "pkg: firefox") }}
{% endif %}

firefox:
  pkg.installed:
    - pkgs:
      - firefox
{%- if grains['osmajorrelease']|int >= 18 and grains['osrelease'] != '18.04' %}
      - webext-ublock-origin
      - webext-umatrix
      - webext-privacy-badger
      - webext-form-history-control
{%- endif %}

