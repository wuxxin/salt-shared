{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("firefox-dev_ppa", "ubuntu-mozilla-daily/firefox-aurora") }}


{% endif %}

browser_nop:
  test:
    - nop
