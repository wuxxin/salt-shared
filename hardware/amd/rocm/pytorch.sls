{% from 'aur/lib.sls' import aur_install, pamac_patch_install_dir with context %}

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
{{ aur_install('python-torchvision-rocm', ['python-torchvision-rocm', ], require='pkg: pytorch') }}

# torchaudio - prerequisites
{{ aur_install('python-kaldi-io', ['python-kaldi-io',], require='pkg: pytorch') }}

# torchaudio - Data manipulation and transformation for audio signal processing
{# aur_install('python-torchaudio-rocm', ['python-torchaudio-rocm', ],
   require=['pkg: pytorch', 'test: python-kaldi-io']) #}
