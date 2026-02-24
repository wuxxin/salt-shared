{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

{% load_yaml as pkgs %}
    # llama.cpp-hip - Port of Facebook's LLaMA model in C/C++ (with AMD ROCm optimizations)
    - llama.cpp-hip
    # python-llama-cpp-hip - Python bindings for llama.cpp (with HIP/ROCM support)
    - python-llama-cpp-hip
    # whisper.cpp - Port of OpenAI's Whisper model in C/C++ (with OpenBLAS + Vulkan optimizations)
    - whisper.cpp-hip
    - whisper.cpp-model-large-v3-turbo-q5_0
{% endload %}
{{ aur_install('llama.cpp-hip', pkgs, require='sls: hardware.amd.rocm') }}

