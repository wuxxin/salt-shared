{% from "nsapwn/defaults.jinja" import settings with context %}

include:
  - kernel.server

nspawn_requisites:
  pkg.installed:
    - pkgs:
      - thin-provisioning-tools
      - bridge-utils
      - ebtables
      - uidmap
    - require:
      - sls: kernel.server
