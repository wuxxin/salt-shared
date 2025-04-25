{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# llama.cpp-hip - Port of Facebook's LLaMA model in C/C++ (with AMD ROCm optimizations)
{{ aur_install('llama.cpp-hip', ['llama.cpp-hip', ], require='sls: hardware.amd.rocm') }}

