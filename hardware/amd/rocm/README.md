# ROCM sdk

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

+ basic pytorch testing
```
HIP_LAUNCH_BLOCKING=1 AMD_LOG_LEVEL=3 \
  python -c "import torch;d=torch.device('cuda:0');
    a=torch.randn(100,device=d,dtype=torch.float);print(a)"
```

+ Command-line to trace HIP APIs and output
```sh
ltrace -C -e "hip*" ./hipGetChanDesc
```
