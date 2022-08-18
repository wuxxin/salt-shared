{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm
  - desktop.manjaro.python.development
  - desktop.manjaro.python.hardware_optimized

pytorch_req:
  test.nop:
    - require:
      - sls: hardware.amd.rocm
      - sls: desktop.manjaro.python.development
      - sls: desktop.manjaro.python.hardware_optimized

# pytorch - Tensors and Dynamic neural networks in Python with strong GPU acceleration
{{ pamac_install('python-pytorch-rocm', ['python-pytorch-rocm', ],
    require='test: pytorch_req') }}

# torchvision - Datasets, transforms, and models specific to computer vision
{{ pamac_install('python-torchvision-rocm', ['python-torchvision-rocm', ],
    require='test: python-pytorch-rocm') }}

# torchaudio - prerequisites
{{ pamac_install('python-kaldi-io', ['python-kaldi-io',],
    require='test: pytorch_req') }}

{#

# torchtext - Data loaders and abstractions for text and NLP
{{ pamac_patch_install_dir('python-torchtext',
    'salt://hardware/amd/rocm/python-torchtext',
    require='test: python-pytorch-rocm', custom=true) }}

# torchaudio - Data manipulation and transformation for audio signal processing
{{ pamac_patch_install_dir('python-torchaudio-rocm',
    'salt://hardware/amd/rocm/python-torchaudio-rocm',
    require=['test: python-pytorch-rocm', 'test: python-kaldi-io'],
    custom=true) }}

# torchrec - Domain library for recommendation systems

#}
