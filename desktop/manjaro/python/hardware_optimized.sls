## hardware optimized python
{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install, pamac_patch_install_dir with context %}

# numpy - scientific computing build with CPU - multicore + CPU-extensions speedup
{{ pamac_install('python-numpy-openblas', ['python-numpy-openblas']) }}

# pillow - Imaging Library (PIL) fork build with CPU - AVX2 speedup
{#
{{ pamac_patch_install_dir('python-pillow-simd',
    'salt://desktop/manjaro/python/python-pillow-simd') }}
      - test: python-pillow-simd
#}

hardware_optimized_python:
  test.nop:
    - require:
      - test: python-numpy-openblas
