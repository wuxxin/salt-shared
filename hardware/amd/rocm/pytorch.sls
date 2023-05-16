{% from 'manjaro/lib.sls' import pamac_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm

# pytorch - Tensors and Dynamic neural networks in Python with strong GPU acceleration
pytorch:
  pkg.installed:
    - pkgs:
      - python-pytorch-opt-rocm
    - require:
      - sls: hardware.amd.rocm
      
# torchvision - Datasets, transforms, and models specific to computer vision
{{ pamac_install('python-torchvision-rocm', ['python-torchvision-rocm', ], require='pkg: pytorch') }}

# torchaudio - prerequisites
{{ pamac_install('python-kaldi-io', ['python-kaldi-io',], require='pkg: pytorch') }}

{#
# torchaudio - Data manipulation and transformation for audio signal processing
# torchtext - Data loaders and abstractions for text and NLP
# torchrec - Domain library for recommendation systems
#}
