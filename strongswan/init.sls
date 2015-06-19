{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu

{% from "repo/ubuntu.sls" import apt_add_repository %}

# saxl/strongswan has strongswan 5.2.1 (which is needed for fragmentation support)
{{ apt_add_repository("strongswan_ppa", "saxl/strongswan") }}

strongswan:
  pkg.installed:
    - require:
      - cmd: strongswan_ppa

{% else %}

strongswan:
  pkg:
    - installed

{% endif %}
