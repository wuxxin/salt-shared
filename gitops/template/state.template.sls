base:

  # physical machine
  'virtual:physical':
    - match: grain
    - hardware

  # virtual machine
  'P@virtual:(?!physical)':
    - match: compound
    - virtual

  # any machine type with a kernel (including virtual) but not on lxc (is same kernel)
  'P@virtual:(?!LXC)':
    - match: compound
    - kernel
    - kernel.entropy
    - kernel.power
    
  # if on lxc/lxd install headers and tools for the running host kernel version
  'virtual:LXC':
    - kernel.running-headers

  # ubuntu specific
  'os:Ubuntu':
    - match: grain
    - ubuntu

  # any
  '*':
    - node
    - tools

  # custom states
  # to disable custom states, add pillar='{"disable_custom": true}' to execution
  'not I@disable_custom:true':
    - match: compound
    - custom
