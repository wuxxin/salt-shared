{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm
  - desktop.manjaro.python.development
  - desktop.manjaro.python.hardware_optimized

{#
# python-tensorflow-opt-rocm - scalable machine learning (with ROCM and AVX2 CPU optimizations)
{{ pamac_install('python-tensorflow-rocm_aur', [ 'python-tensorflow-opt-rocm',],
    require= [
      'sls: hardware.amd.rocm',
      'sls: desktop.manjaro.python.development',
      'sls: desktop.manjaro.python.hardware_optimized',
    ]) }}

#}

amd_rocm_tensorflow:
  test:
    - nop
