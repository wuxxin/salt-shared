{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.radeon
  - code.python.dev

rocm-sdk:
  pkg.installed:
    - pkgs:
      - rocm-hip-sdk
      - roctracer
      - rocminfo
      # rocwmma - Library for accelerating mixed precision matrix multiplication
      - rocwmma
      # magma-hip - Matrix Algebra on GPU and Multicore Architectures (with ROCm/HIP)
      - magma-hip
      # amdsmi - AMD System Management Interface library
      - amdsmi
    - require:
      - sls: hardware.amd.radeon
      - sls: code.python.dev

rocm-opencl:
  pkg.installed:
    - pkgs:
      # rocm-opencl-sdk - Develop OpenCL-based applications for AMD platforms
      - rocm-opencl-sdk
      # rocm-opencl-runtime - OpenCL implementation for AMD
      - rocm-opencl-runtime
    - require:
      - sls: hardware.amd.radeon
      - sls: code.python.dev

hardware-amd-rocm:
  test:
    - nop
    - require:
      - pkg: rocm-sdk
      - pkg: rocm-opencl

