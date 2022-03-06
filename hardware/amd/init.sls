{# make system and initrd utility aware of the needed kernel modules #}
/etc/modules-load.d/amd-gpu.conf:
  file.managed:
    - contents: |
        amdgpu

{# add other and gpu related tools #}
