{% from 'aur/lib.sls' import aur_install, pamac_patch_install_dir with context %}

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
      - opencl-mesa
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
      - manjaro-vaapi
      - gstreamer-vaapi
      - libva-mesa-driver
      - libva-utils

vdpau:
  pkg.installed:
    - pkgs:
      - mesa-vdpau
      - vdpauinfo

radeon:
  pkg.installed:
    - pkgs:
      - radeontop
      - radeontool

{% load_yaml as pkgs %}
      # lact - AMDGPU Controller application
      - lact
{% endload %}
{{ aur_install('radeon-aur', pkgs, require= 'pkg: radeon') }}
