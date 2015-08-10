{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("firefox-dev_ppa", "ubuntu-mozilla-daily/firefox-aurora") }}
{{ apt_add_repository("qupzilla_ppa", "nowrep/qupzilla") }}
{{ apt_add_repository("midori_ppa", "midori/ppa") }}

{% endif %}
