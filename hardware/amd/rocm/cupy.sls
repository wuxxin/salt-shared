{% from 'aur/lib.sls' import aur_install, pamac_patch_install_dir with context %}

include:
  - hardware.amd.rocm

# cupy - NumPy & SciPy for GPU 
#  CuPy acts as a drop-in replacement to run existing NumPy/SciPy code on NVIDIA CUDA or AMD ROCm platforms.
{{ aur_install('python-cupy-rocm', ['python-cupy-rocm', ], require='sls: hardware.amd.rocm') }}
