include:
  - hardware.amd.radeon
  - python.dev

rocm-sdk:
  pkg.installed:
    - pkgs:
      - rocm-hip-sdk
      - rocm-opencl-sdk
      - roctracer
      - rocminfo
    - require:
      - sls: hardware.amd.radeon
      - sls: python.dev

hardware-amd-rocm:
  test:
    - nop
    - require:
      - pkg: rocm-sdk

