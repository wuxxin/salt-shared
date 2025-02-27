{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# koboldcpp-hipblas - simple one-file way to run various GGML and GGUF models with KoboldAI's UI. (HIPBLAS build)
{{ aur_install('koboldcpp-hipblas', ['koboldcpp-hipblas', ], require='sls: hardware.amd.rocm') }}

