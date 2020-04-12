{# make system and initrd utility aware of the needed kernel modules #}
/etc/modules-load.d/amd.conf:
  file.managed:
    - contents: |
        amd-rng
        kvm_amd
        amdgpu

{# add other and gpu related tools #}