{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}
include:
  - repo.ubuntu
{% endif %}

{% if (grains['os'] == 'Ubuntu' or grains['os'] == 'Mint') %}

{% from "repo/ubuntu.sls" import apt_add_repository %}
{{ apt_add_repository("x265-ppa", "strukturag/libde265") }}

{{ apt_add_repository("minitube-ppa", "noobslab/apps") }}

{{ apt_add_repository("rvm_smplayer_ppa", "rvm/smplayer") }}


{% endif %}
