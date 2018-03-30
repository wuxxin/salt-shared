{% from "roles/imgbuilder/defaults.jinja" import settings as s with context %}

include:
  - roles.libvirt
  - .dirs
  - .user
  - .packer
  - .preseed
{%- if s.include_vagrant %}
  - .vagrant
{%- endif %}
