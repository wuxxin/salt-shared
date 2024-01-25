{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# python-tensorflow-opt-rocm - scalable machine learning (with ROCM and AVX2 CPU optimizations)
{{ aur_install('python-tensorflow-rocm-aur', [ 'python-tensorflow-opt-rocm',],
    require= 'sls: hardware.amd.rocm') }}
