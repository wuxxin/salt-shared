# hardware optimized python packages
{% from 'manjaro/lib.sls' import pamac_install with context %}

# numpy - scientific computing build with CPU - multicore + CPU-extensions speedup
# pillow - Imaging Library (PIL) fork build with CPU - SSE4 speedup
{{ pamac_install('python_hardware_optimized', [
    'python-numpy-openblas',
    'python-pillow-simd',
    ]) }}

hardware_optimized:
  test.nop:
    - require:
      - test: python_hardware_optimized
