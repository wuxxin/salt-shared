{% from 'arch/lib.sls' import aur_install with context %}

include:
  - hardware.amd.rocm

# localai-git-rocm - Self-hosted OpenAI API alternative - Open Source, community-driven and local-first. (with ROCM support)
{{ aur_install('localai-git-rocm', ['localai-git-rocm', ], require='sls: hardware.amd.rocm') }}

