{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

ollama:
  pkg.installed:
    - pkgs:
      - ollama-rocm
    - require:
      - sls: hardware.amd.rocm
