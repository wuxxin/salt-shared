{% from 'aur/lib.sls' import aur_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm

{{ aur_install('python-jax-rocm-aur', ['python-jax-rocm'], require= "sls: hardware.amd.rocm") }}
