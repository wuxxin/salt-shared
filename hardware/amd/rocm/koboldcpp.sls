{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# koboldcpp - simple one-file way to run various GGML and GGUF models with KoboldAI's UI. (vulkan version)
{{ aur_install('koboldcpp', ['koboldcpp', ], require='sls: hardware.amd.rocm') }}

