{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm
  - desktop.manjaro.python.hardware_optimized

{{ pamac_install('python-tensorflow-rocm_aur', [
    'tensorflow-rocm',
    ], require= 'sls: hardware.amd.rocm') }}
