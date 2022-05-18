{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - manjaro.aur
  - hardware.amd.radeon

{{ pamac_install('rocm-sdk', [
  'rocminfo',
  'rocm-hip-sdk',
  'rocm-opencl-sdk',
  'miopen-hip',
  'hipmagma',
  ]) }}

hardware-amd-rocm:
  test:
    - nop
    - require:
      - test: rocm-sdk
