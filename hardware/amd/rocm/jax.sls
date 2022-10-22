{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm
  - desktop.manjaro.python.development
  - desktop.manjaro.python.hardware_optimized

jax_req:
  test.nop:
    - require:
      - sls: hardware.amd.rocm
      - sls: desktop.manjaro.python.development
      - sls: desktop.manjaro.python.hardware_optimized

{{ pamac_install('python-jax-rocm-aur', ['python-jax-rocm'],
    require= "test: jax_req") }}
