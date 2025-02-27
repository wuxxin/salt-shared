{% from 'arch/lib.sls' import aur_install with context %}

# make system and initrd utility aware of the needed kernel modules
/etc/modules-load.d/amd-gpu.conf:
  file.managed:
    - contents: |
        amdgpu

vulkan:
  pkg.installed:
    - pkgs:
      - vulkan-radeon
      - vulkan-mesa-layers
      - vulkan-icd-loader
      - vulkan-tools

opengl:
  pkg.installed:
    - pkgs:
      - mesa
      - mesa-utils

opencl:
  pkg.installed:
    - pkgs:
      - opencl-headers
      - ocl-icd
      - clinfo

clblast:
  pkg.installed:
    - pkgs:
      # clblast - Tuned OpenCL BLAS library
      - clblast
    - require:
      - pkg: opencl

vaapi:
  pkg.installed:
    - pkgs:
      - libva-utils

vdpau:
  pkg.installed:
    - pkgs:
      - vdpauinfo

gputools:
  pkg.installed:
    - pkgs:
      # radeontop - View GPU utilization for total activity percent and individual block
      - radeontop
      # radeontool - Lowlevel tools to tweak register and dump state on radeon GPUs
      - radeontool
      # nvtop - GPUs process monitoring for AMD, Intel and NVIDIA
      - nvtop
{% load_yaml as pkgs %}
      # lact - AMDGPU Controller application
      - lact
      # amdgpu_top - Tool that shows AMD GPU utilization
      - amdgpu_top
{% endload %}
{{ aur_install('gputools-aur', pkgs, require= 'pkg: gputools') }}
