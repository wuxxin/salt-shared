# make system and initrd utility aware of the needed kernel modules
/etc/modules-load.d/amd-gpu.conf:
  file.managed:
    - contents: |
        amdgpu

{% if grains['os'] == 'Manjaro' %}
# install gpu related tools

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

{% endif %}
