{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("mozillateam_firefox_beta_ppa",
  "mozillateam/firefox-next", require_in= "pkg: firefox") }}
{% endif %}

firefox:
  pkg.installed:
    - pkgs:
      - firefox
{%- if grains['os'] == 'Ubuntu' and
    grains['osmajorrelease']|int >= 18 and
    grains['osrelease'] != '18.04' %}
      - webext-ublock-origin
      - webext-privacy-badger
      - webext-form-history-control
{%- endif %}
