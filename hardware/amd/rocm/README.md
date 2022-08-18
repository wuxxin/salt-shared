# ROCM sdk

+ packages needed for python-pytorch-rocm and tensorflow-rocm

```
hip-runtime-amd rocm-llvm rocm-hip-sdk rocm-opencl-sdk
rocm-clang-ocl hsa-rocr rocprofiler roctracer rocm-llvm-mlir miopengemm miopen-hip
```

+ see https://docs.amd.com/bundle/AMD_HIP_Programming_Guide/page/Programming_with_HIP.html

+ set environment (eg. /etc/environment.d/gpu_targets.conf)
```sh
# select targethardware using: AMDGPU_TARGETS="targetgpu;targetgpu"
AMDGPU_TARGETS="gfx90c;gfx1030"
# do not list apu/igpu of AMD Ryzen 7 PRO 5750G with Radeon Graphics
ROCR_VISIBLE_DEVICES=0
```

+ debug env settings
```sh
# Syncron call of hip components
HIP_LAUNCH_BLOCKING=1
# By default, HIP logging is disabled, it can be enabled via AMD_LOG_LEVEL
AMD_LOG_LEVEL=3
```

HIP_LAUNCH_BLOCKING=1 AMD_LOG_LEVEL=3 \
  python -c "import torch;d=torch.device('cuda:0');
    a=torch.randn(100,device=d,dtype=torch.float);print(a)"

_ZN2at6native6modern18elementwise_kernelINS0_13BUnaryFunctorIfffNS0_10MulFunctorIfEEEENS_6detail5ArrayIPcLi2EEEEEviT_T0_
_ZN2at6native6modern18elementwise_kernelINS0_13BUnaryFunctorIfffNS0_10MulFunctorIfEEEENS_6detail5ArrayIPcLi2EEEEEviT_T0_

+ Command-line to trace HIP APIs and output
```sh
ltrace -C -e "hip*" ./hipGetChanDesc
```
