{% from "ubuntu/init.sls" import apt_add_repository %}

{{ apt_add_repository("torbrowser_ppa", "micahflee/ppa",
  require_in = "pkg: torbrowser-launcher") }}

torbrowser-launcher:
  pkg:
    - installed
