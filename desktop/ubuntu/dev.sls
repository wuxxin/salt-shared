ubuntu-dev-tools:
  pkg.installed:
    - pkgs:
      - devscripts
      - ubuntu-dev-tools

{% from "ubuntu/lib.sls" import apt_add_repository %}
{{ apt_add_repository("cubic_ppa", "cubic-wizard/release",
  require_in = "pkg: cubic") }}

cubic:
  pkg.installed:
    - names:
      - cubic
