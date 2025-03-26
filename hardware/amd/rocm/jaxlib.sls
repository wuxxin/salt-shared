{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# python-jaxlib-rocm - XLA library for JAX (with ROCM support)
{{ aur_install('python-jaxlib-rocm-aur', [ 'python-jaxlib-rocm',],
    require= 'sls: hardware.amd.rocm') }}
