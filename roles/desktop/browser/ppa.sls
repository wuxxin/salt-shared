{% if grains['os'] == 'Ubuntu' %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("firefox-dev_ppa", "ubuntu-mozilla-daily/firefox-aurora") }}

{{ apt_add_repository("firefox-esr_ppa", "jonathonf/firefox-esr") }}

{% endif %}

browser_nop:
  test:
    - nop
