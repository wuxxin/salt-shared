{% if grains['os'] == 'Ubuntu' %}
{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("workrave_ppa",
  "rob-caelers/workrave", require_in= "pkg: workrave") }}

vanilla-workrave:
  pkg.removed:
    - name: workrave

workrave:
  pkg.installed:
    - pkgs:
      - workrave-gnome
    - require:
      - pkg: vanilla-workrave

{% else %}

workrave:
  pkg.installed:
    - pkgs:
      - workrave
{% endif %}
