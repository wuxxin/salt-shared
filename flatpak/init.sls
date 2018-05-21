include:
  - ubuntu

{% from "unbound/defaults.jinja" import settings as s with context %}

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("flatpak-ppa", "alexlarsson/flatpak",
  require_in = "pkg: flatpak") }}

flatpak:
  pkg.installed:
    - require:
      - pkgrepo: flatpak-ppa
