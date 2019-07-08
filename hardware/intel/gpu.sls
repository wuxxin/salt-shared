
{# enable vgpu, enable gpu firmware loading, needs kernel restart #}
/etc/modprobe.d/intel-gpu.cfg:
  file.managed:
    - contents: |
        options i915 enable_gvt=1
        options i915 enable_guc=2

{# make system and initrd utility aware of the needed kernel modules for kvmgt #}
/etc/modules-load.d/intel-gpu.conf:
  file.managed:
    - contents: |
        i915
        mdev
        vfio
        vfio-iommu-type1
        vfio-mdev
        kvm
        kvm-intel
        kvmgt

{# add beignet and other intel gpu related tools #}