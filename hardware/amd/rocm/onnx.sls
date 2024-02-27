{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# onnx - Cross-platform, high performance scoring engine for ML models 
onnx:
  pkg.installed:
    - pkgs:
      - onnxruntime-opt-rocm
      - python-onnxruntime-opt-rocm
    - require:
      - sls: hardware.amd.rocm
      