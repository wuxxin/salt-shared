include:
  - ubuntu

{% from "ubuntu/init.sls" import apt_add_repository %}
{{ apt_add_repository("cubic-ppa", "cubic-wizard/release",
  require_in = "pkg: cubic") }}

cubic:
  pkg.installed:
    - names:
      - cubic
