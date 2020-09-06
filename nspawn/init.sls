{% from "nsapwn/defaults.jinja" import settings with context %}

{# modify kernel for production http://lxd.readthedocs.io/en/latest/production-setup/ #}
include:
  - kernel.server

nspawn_requisites:
  pkg.installed:
    - pkgs:
      - thin-provisioning-tools
      - bridge-utils
      - ebtables
      - uidmap
      - sls: kernel.server
