{% from 'manjaro/lib.sls' import pamac_install with context %}

include:
  - hardware.amd.rocm
  - desktop.manjaro.python.development
  - desktop.manjaro.python.hardware_optimized

# pytorch - Tensors and Dynamic neural networks in Python with strong GPU acceleration
{{ pamac_install('python-pytorch-rocm', ['python-pytorch-rocm', ],
    require=[
      'sls: hardware.amd.rocm',
      'sls: desktop.manjaro.python.development',
      'sls: desktop.manjaro.python.hardware_optimized',
    ]) }}

# torchvision - Datasets, transforms, and models specific to computer vision
{{ pamac_install('python-torchvision-rocm', ['python-torchvision-rocm', ],
    require='test: python-pytorch-rocm') }}

# torchaudio - Data manipulation and transformation for audio signal processing
{{ pamac_install('python-kaldi-io', ['python-kaldi-io',],
    require=[
      'sls: desktop.manjaro.python.development',
      'sls: desktop.manjaro.python.hardware_optimized',
      ]) }}

{#

{{ pamac_patch_install_dir('python-torchaudio-rocm',
    'salt://hardware/amd/rocm/python-torchaudio-rocm',
    require=[
      'test: python-pytorch-rocm',
      'test: python-kaldi-io'
    ], custom=true) }}

# torchrec - Domain library for recommendation systems

#}
