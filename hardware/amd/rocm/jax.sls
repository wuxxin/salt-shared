{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm

{{ pamac_install('python-jax-rocm-aur', ['python-jax-rocm'], require= "sls: hardware.amd.rocm") }}
