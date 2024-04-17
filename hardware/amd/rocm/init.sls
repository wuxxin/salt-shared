include:
  - hardware.amd.radeon
  - python.dev

rocm-sdk:
  pkg.installed:
    - pkgs:
      - rocm-hip-sdk
      - roctracer
      - rocminfo
    - require:
      - sls: hardware.amd.radeon
      - sls: python.dev

rocm-magma:
  pkg.installed:
    - pkgs:
      # magma-hip - Matrix Algebra on GPU and Multicore Architectures (with ROCm/HIP)
      - magma-hip
    - require:
      - pkg: rocm-sdk

rocm-opencl:
  pkg.installed:
    - pkgs:
      # rocm-opencl-sdk - Develop OpenCL-based applications for AMD platforms
      - rocm-opencl-sdk
      # rocm-opencl-runtime - OpenCL implementation for AMD
      - rocm-opencl-runtime
    - require:
      - sls: hardware.amd.radeon
      - sls: python.dev

hardware-amd-rocm:
  test:
    - nop
    - require:
      - pkg: rocm-sdk
      - pkg: rocm-opencl

