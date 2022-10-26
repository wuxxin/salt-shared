{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - manjaro.aur
  - manjaro.arch4edu
  - hardware.amd.radeon

{{ pamac_install('rocm-sdk', [
  'rocminfo',
  'rocm-hip-sdk',
  'rocm-opencl-sdk',
  'miopen-hip',
  'hip-runtime-amd',
  ]) }}

hardware-amd-rocm:
  test:
    - nop
    - require:
      - test: rocm-sdk
